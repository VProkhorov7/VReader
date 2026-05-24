#!/usr/bin/env python3
"""
VReader project pre-publish validator.

Run from project root:

    python3 Description/check_refs.py

Purpose:
- catch obvious broken project references before publishing AI-generated changes;
- avoid false positives for Apple/system framework types;
- ignore nested Swift helper types such as CodingKeys.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "App" / "Vreader" / "Vreader"
IOS_TARGET = 17

if not PROJECT.exists():
    print(f"❌ Project folder not found: {PROJECT}")
    sys.exit(1)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def load_swift_files() -> dict[str, str]:
    files: dict[str, str] = {}
    for path in sorted(PROJECT.glob("*.swift")):
        files[path.name] = read_text(path)
    return files


def strip_noise(code: str) -> str:
    """Remove comments and string literals before regex scanning."""
    code = re.sub(r'"[^"\\]*(?:\\.[^"\\]*)*"', '""', code)
    code = re.sub(r"//[^\n]*", "", code)
    code = re.sub(r"/\*.*?\*/", "", code, flags=re.DOTALL)
    return code


# Swift / Apple / imported framework types that should not be reported as unresolved.
SYSTEM_TYPES = {
    # Swift core
    "String", "Substring", "Character", "Int", "Int8", "Int16", "Int32", "Int64",
    "UInt", "UInt8", "UInt16", "UInt32", "UInt64", "Double", "Float", "Bool",
    "Optional", "Array", "Set", "Dictionary", "Result", "Error", "Void", "Any",
    "AnyHashable", "AnyObject", "Never", "Self", "Sendable", "Hashable",
    "Equatable", "Comparable", "CaseIterable", "RawRepresentable", "Codable",
    "Encodable", "Decodable", "CodingKey", "Decoder", "Encoder", "KeyedDecodingContainer",
    "KeyedEncodingContainer",

    # Foundation
    "Date", "UUID", "URL", "Data", "Locale", "Calendar", "TimeZone", "IndexSet",
    "Bundle", "UserDefaults", "Notification", "NotificationCenter", "Timer",
    "DateFormatter", "ISO8601DateFormatter", "ByteCountFormatter", "FileManager",
    "URLSession", "URLRequest", "URLResponse", "HTTPURLResponse", "URLComponents",
    "URLQueryItem", "URLCredential", "URLResourceKey", "NSError", "NSObject",
    "NSPredicate", "NSRange", "NSAttributedString", "NSLocalizedString",
    "NSMetadataQuery", "NSUbiquitousKeyValueStore", "NSKeyValueChangeKey",
    "NSMetadataQueryUbiquitousDocumentsScope", "Progress", "CharacterSet", "Scanner",

    # CoreGraphics
    "CGFloat", "CGPoint", "CGSize", "CGRect",

    # SwiftUI
    "View", "App", "Scene", "EnvironmentKey", "ObservableObject", "Observable",
    "Identifiable", "LocalizedError", "Published", "State", "Binding", "StateObject",
    "ObservedObject", "EnvironmentObject", "AppStorage", "Environment", "Query",
    "FetchDescriptor", "SortDescriptor", "Color", "Font", "Image", "Text", "Button",
    "Spacer", "Divider", "List", "ForEach", "VStack", "HStack", "ZStack", "ScrollView",
    "NavigationStack", "NavigationLink", "NavigationPath", "TabView", "Form", "Section",
    "Label", "Slider", "Picker", "TextField", "SecureField", "Group", "GeometryReader",
    "GeometryProxy", "ContentUnavailableView", "ProgressView", "RoundedRectangle",
    "Rectangle", "Capsule", "Circle", "LinearGradient", "Animation", "ViewBuilder",
    "Toolbar", "ToolbarItem", "ToolbarItemPlacement", "GridItem", "LazyVGrid",
    "LazyVStack", "DragGesture", "TapGesture", "UnitPoint", "Sheet", "StrokeStyle",
    "EmptyView", "Toggle", "LabeledContent",

    # SwiftData
    "Model", "ModelContext", "ModelContainer", "ModelConfiguration", "Schema",

    # UIKit / AppKit bridge
    "UIImage", "NSImage", "UIView", "UIImageView", "UIScrollView", "UIViewRepresentable",
    "UIGestureRecognizer", "UITapGestureRecognizer", "UISwipeGestureRecognizer",
    "UIPanGestureRecognizer",

    # WebKit
    "WKWebView", "WKWebViewConfiguration", "WKNavigationDelegate", "WKNavigation",
    "WKNavigationAction", "WKNavigationActionPolicy", "WKScriptMessage",
    "WKUserContentController", "WKScriptMessageHandler",

    # PDFKit / ZIPFoundation
    "PDFView", "PDFDocument", "PDFPage", "Archive",

    # AVFoundation / CoreMedia
    "AVPlayer", "AVPlayerItem", "AVURLAsset", "AVMetadataItem", "CMTime", "TimeInterval",

    # Network / OSLog / UniformTypeIdentifiers
    "NWPath", "NWPathMonitor", "Logger", "UTType",

    # Security / concurrency / Combine
    "OSStatus", "CFString", "SecItemAdd", "SecItemCopyMatching", "SecItemDelete",
    "Task", "DispatchQueue", "MainActor", "UnsafeMutableRawPointer",
    "AnyCancellable", "AnyPublisher",

    # Common local nested/helper names that should not be treated as global duplicates.
    "Coordinator", "Context", "Keys", "CodingKeys",
}

IGNORED_DUPLICATE_TYPE_NAMES = {
    "Coordinator",
    "CodingKeys",
    "Keys",
    "Context",
}

VIEW_FILES = {
    "LibraryView.swift",
    "BookCardView.swift",
    "ReadingView.swift",
    "ReadingSessionView.swift",
    "ReaderView.swift",
    "BookDetailView.swift",
    "TextReaderView.swift",
    "ComicReaderView.swift",
    "AudioPlayerView.swift",
}

API_VERSIONS = {
    # iOS 13
    "ignoresSafeArea": 13,
    "LazyVGrid": 13,
    "LazyHGrid": 13,

    # iOS 14
    "StateObject": 14,
    "AppStorage": 14,
    "SceneStorage": 14,
    "fullScreenCover": 14,
    "ProgressView": 14,
    "VideoPlayer": 14,

    # iOS 15
    "swipeActions": 15,
    "searchable": 15,
    "refreshable": 15,
    "symbolRenderingMode": 15,
    "symbolVariant": 15,
    "FocusState": 15,
    "AsyncImage": 15,
    "safeAreaInset": 15,

    # iOS 16
    "toolbarBackground": 16,
    "toolbarColorScheme": 16,
    "NavigationStack": 16,
    "NavigationSplitView": 16,
    "GridRow": 16,
    "Layout": 16,
    "ViewThatFits": 16,
    "AnyLayout": 16,
    "ShareLink": 16,
    "LabeledContent": 16,
    "MultiDatePicker": 16,

    # iOS 17
    "ContentUnavailableView": 17,
    "TipKit": 17,
    "scrollPosition": 17,
    "scrollTargetBehavior": 17,
    "ScrollTargetBehavior": 17,
    "Observable": 17,
    "Observation": 17,
    "onChange": 17,
    "MapKit": 17,
    "SwiftData": 17,
    "ModelContainer": 17,
    "ModelContext": 17,
    "Query": 17,
    "Model": 17,
}


def collect_type_definitions(files: dict[str, str]) -> dict[str, list[str]]:
    definitions: dict[str, list[str]] = {}
    pattern = re.compile(r"\b(?:struct|final\s+class|class|enum|protocol|actor)\s+([A-Z]\w+)")
    for fname, content in files.items():
        for match in pattern.finditer(content):
            definitions.setdefault(match.group(1), []).append(fname)
    return definitions


def check_duplicate_types(definitions: dict[str, list[str]]) -> bool:
    ok = True
    duplicates = {
        name: sorted(set(files))
        for name, files in definitions.items()
        if len(set(files)) > 1 and name not in IGNORED_DUPLICATE_TYPE_NAMES
    }

    if duplicates:
        ok = False
        print("❌ ДУБЛИКАТЫ ТИПОВ:")
        for name, files in sorted(duplicates.items()):
            for fname in files:
                print(f"   {name} в {fname}")
    return ok


def collect_type_references(code: str) -> set[str]:
    clean = strip_noise(code)
    refs: set[str] = set()

    patterns = [
        r":\s*([A-Z]\w+)",
        r"->\s*([A-Z]\w+)",
        r"\b([A-Z]\w+)\s*\(",
        r"[<\[]\s*([A-Z]\w+)",
        r"\bas\??\s+([A-Z]\w+)",
    ]

    for pattern in patterns:
        for match in re.finditer(pattern, clean):
            refs.add(match.group(1))

    return refs


def check_unresolved_types(files: dict[str, str], definitions: dict[str, list[str]]) -> bool:
    ok = True
    all_project_types = set(definitions.keys())
    issues: list[tuple[str, list[str]]] = []

    local_def_re = re.compile(r"\b(?:struct|final\s+class|class|enum|protocol|actor)\s+([A-Z]\w+)")

    for fname, content in sorted(files.items()):
        local_types = {m.group(1) for m in local_def_re.finditer(content)}
        refs = collect_type_references(content)
        missing = sorted(
            ref for ref in refs
            if ref not in all_project_types
            and ref not in SYSTEM_TYPES
            and ref not in local_types
        )
        if missing:
            issues.append((fname, missing))

    if issues:
        ok = False
        print("❌ НЕРАЗРЕШЁННЫЕ ТИПЫ:")
        for fname, missing in issues:
            print(f"   {fname}: {missing}")
    return ok


def check_book_properties(files: dict[str, str]) -> bool:
    ok = True
    book_props: set[str] = set()

    book_model = files.get("Book.swift", "")
    for match in re.finditer(r"\bvar\s+(\w+)\s*[=:]", book_model):
        book_props.add(match.group(1))

    for fname, content in files.items():
        for ext_match in re.finditer(r"extension\s+Book\s*\{(.*?)\n\}", content, re.DOTALL):
            for match in re.finditer(r"\bvar\s+(\w+)\b", ext_match.group(1)):
                book_props.add(match.group(1))

    issues: list[tuple[str, list[str]]] = []
    for fname, content in sorted(files.items()):
        if fname not in VIEW_FILES:
            continue
        used = re.findall(r"\bbook\.([a-z]\w+)", strip_noise(content))
        missing = sorted(set(prop for prop in used if prop not in book_props))
        if missing:
            issues.append((fname, missing))

    if issues:
        ok = False
        print("❌ НЕИЗВЕСТНЫЕ СВОЙСТВА Book:")
        for fname, missing in issues:
            print(f"   {fname}: book.{{{', '.join(missing)}}}")
    return ok


def check_appstate_members(files: dict[str, str]) -> bool:
    ok = True
    appstate_members: set[str] = set()
    appstate_src = files.get("AppState.swift", "")

    for match in re.finditer(r"\bvar\s+(\w+)\b", appstate_src):
        appstate_members.add(match.group(1))
    for match in re.finditer(r"\bfunc\s+(\w+)\b", appstate_src):
        appstate_members.add(match.group(1))

    issues: list[tuple[str, list[str]]] = []
    for fname, content in sorted(files.items()):
        used = re.findall(r"appState\.(\w+)", strip_noise(content))
        missing = sorted(set(member for member in used if member not in appstate_members))
        if missing:
            issues.append((fname, missing))

    if issues:
        ok = False
        print("❌ НЕИЗВЕСТНЫЕ ЧЛЕНЫ AppState:")
        for fname, missing in issues:
            print(f"   {fname}: appState.{{{', '.join(missing)}}}")
    return ok


def check_balanced_braces(files: dict[str, str]) -> bool:
    ok = True
    issues: list[tuple[str, int, int]] = []

    for fname, content in sorted(files.items()):
        clean = strip_noise(content)
        opens = clean.count("{")
        closes = clean.count("}")
        if opens != closes:
            issues.append((fname, opens, closes))

    if issues:
        ok = False
        print("❌ НЕСБАЛАНСИРОВАННЫЕ СКОБКИ:")
        for fname, opens, closes in issues:
            print(f"   {fname}: {{ {opens} vs }} {closes}")
    return ok


def check_ios_api_compatibility(files: dict[str, str]) -> bool:
    ok = True
    issues: list[tuple[str, list[str]]] = []

    for fname, content in sorted(files.items()):
        file_issues: list[str] = []
        clean = strip_noise(content)
        for api, min_ios in API_VERSIONS.items():
            if min_ios > IOS_TARGET and re.search(r"\b" + re.escape(api) + r"\b", clean):
                file_issues.append(f"{api} (iOS {min_ios}+)")
        if file_issues:
            issues.append((fname, file_issues))

    if issues:
        ok = False
        print(f"❌ API ВЫШЕ iOS {IOS_TARGET} DEPLOYMENT TARGET:")
        for fname, file_issues in issues:
            print(f"   {fname}: {file_issues}")
    else:
        print(f"✅ Все API совместимы с iOS {IOS_TARGET}+")
    return ok


def check_project_specific_rules(files: dict[str, str]) -> bool:
    ok = True

    book_model = files.get("Book.swift", "")
    if re.search(r"\bcoverData\s*:\s*Data\b", book_model):
        ok = False
        print("❌ Book.swift: запрещено возвращать coverData: Data в SwiftData-модель. Используй coverPath: String?")

    combined = "\n".join(files.values())
    if re.search(r"isPremium.*CKRecord|CKRecord.*isPremium", combined, re.DOTALL):
        ok = False
        print("❌ isPremium не должен синхронизироваться через CloudKit/CKRecord")

    if re.search(r"WKWebView.*OAuth|OAuth.*WKWebView", combined, re.DOTALL | re.IGNORECASE):
        ok = False
        print("❌ OAuth через WKWebView запрещён. Используй ASWebAuthenticationSession")

    return ok


def main() -> int:
    files = load_swift_files()
    if not files:
        print(f"❌ No Swift files found in {PROJECT}")
        return 1

    ok = True
    definitions = collect_type_definitions(files)

    ok = check_duplicate_types(definitions) and ok
    ok = check_unresolved_types(files, definitions) and ok
    ok = check_book_properties(files) and ok
    ok = check_appstate_members(files) and ok
    ok = check_balanced_braces(files) and ok
    ok = check_ios_api_compatibility(files) and ok
    ok = check_project_specific_rules(files) and ok

    if ok:
        print("✅ Проект чист — можно публиковать")
        return 0

    print("\n⛔ Исправь ошибки перед публикацией")
    return 1


if __name__ == "__main__":
    sys.exit(main())
