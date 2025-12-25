#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import datetime
import html
import os
import sys
import xml.etree.ElementTree as ET
from typing import List, Tuple


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Convert JUnit XML to HTML with total time and success rate")
    p.add_argument("xml", help="Path to JUnit XML file")
    p.add_argument("-o", "--out", help="Output HTML path. Defaults to <xml_basename>_with_summary.html")
    return p.parse_args()


def ensure_float(s: str) -> float:
    try:
        return float(s)
    except Exception:
        return 0.0


def collect_tests(xml_path: str) -> Tuple[int, int, int, int, float, List[dict]]:
  tree = ET.parse(xml_path)
  root = tree.getroot()

  # JUnit can have either <testsuites> or <testsuite> as root
  if root.tag.endswith("testsuites"):
    suites = list(root.findall(".//testsuite"))
  elif root.tag.endswith("testsuite"):
    suites = [root]
  else:
    suites = list(root.findall(".//testsuite"))

  total_time = 0.0
  cases: List[dict] = []
  count_failures = 0
  count_errors = 0
  count_skipped = 0
  count_passed = 0

  for suite in suites:
    for tc in suite.findall("testcase"):
      name = tc.get("name") or "(unnamed)"
      classname = tc.get("classname") or ""
      time_val = ensure_float(tc.get("time") or 0)
      total_time += time_val

      outcome = "passed"
      details = ""
      err = tc.find("error")
      fail = tc.find("failure")
      skip = tc.find("skipped")
      if err is not None:
        outcome = "failed"
        details = (err.get("message") or "error")
        count_errors += 1
      elif fail is not None:
        outcome = "failed"
        details = (fail.get("message") or "failure")
        count_failures += 1
      elif skip is not None:
        outcome = "skipped"
        details = (skip.get("message") or "skipped")
        count_skipped += 1
      else:
        # Treat zero-duration tests as skipped
        if time_val <= 0.0:
          outcome = "skipped"
          count_skipped += 1
        else:
          count_passed += 1

      # stdout/stderr if present
      system_out = tc.find("system-out")
      system_err = tc.find("system-err")
      stdout_text = system_out.text if system_out is not None and system_out.text else ""
      stderr_text = system_err.text if system_err is not None and system_err.text else ""

      cases.append({
        "name": name,
        "classname": classname,
        "time": time_val,
        "outcome": outcome,
        "details": details,
        "stdout": stdout_text,
        "stderr": stderr_text,
      })

  total_tests = len(cases)
  return total_tests, count_failures, count_errors, count_skipped, total_time, cases


def format_display_title(basename: str) -> str:
    """Extract a concise display title from the XML filename.
    If the basename (without extension) ends with two underscore-separated numeric tokens
    (e.g., YYYYMMDD_HHMMSS), return those. Otherwise, return the basename without extension.
    """
    name = os.path.splitext(basename)[0]
    parts = name.split("_")
    if len(parts) >= 2 and parts[-1].isdigit() and parts[-2].isdigit():
        return f"{parts[-2]}_{parts[-1]}"
    return name


def render_html(title: str, tests: int, failures: int, errors: int, skipped: int, total_time: float, cases: List[dict]) -> str:
    passed = max(0, tests - failures - errors - skipped)
    executed = max(0, tests - skipped)
    success_rate = (passed / executed * 100.0) if executed > 0 else 0.0

    def pct_class(rate: float) -> str:
        if rate >= 90:
            return "good"
        if rate >= 70:
            return "warn"
        return "bad"

    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def split_name(name: str) -> Tuple[str, str]:
      # Split at the first space. Before -> test type, after -> test case
      if not name:
        return "", ""
      parts = name.split(" ", 1)
      if len(parts) == 1:
        return parts[0], ""
      return parts[0], parts[1]

    # Build pie chart (成功/失敗/スキップ) as SVG
    def pie_svg(passed_count: int, failed_count: int, skipped_count: int, total_count: int) -> str:
        if total_count <= 0 or (passed_count + failed_count + skipped_count) == 0:
            return "<div class='muted'>データなし</div>"

        cx, cy, r = 100, 100, 90
        start_angle = -90.0  # Start at top

        def polar_to_xy(angle_deg: float) -> Tuple[float, float]:
            import math
            rad = math.radians(angle_deg)
            return cx + r * math.cos(rad), cy + r * math.sin(rad)

        def arc_path(start_deg: float, sweep_deg: float) -> str:
            # Wedge from center to arc end
            end_deg = start_deg + sweep_deg
            x1, y1 = polar_to_xy(start_deg)
            x2, y2 = polar_to_xy(end_deg)
            large_arc = 1 if sweep_deg > 180 else 0
            return (
                f"M {cx} {cy} L {x1:.3f} {y1:.3f} "
                f"A {r} {r} 0 {large_arc} 1 {x2:.3f} {y2:.3f} Z"
            )

        segments = [
            ("成功", passed_count, "#065f46"),
            ("失敗", failed_count, "#b91c1c"),
            ("スキップ", skipped_count, "#92400e"),
        ]

        svg_paths = []
        current = start_angle
        for label, value, color in segments:
            if value <= 0:
                continue
            sweep = (value / total_count) * 360.0
            d = arc_path(current, sweep)
            svg_paths.append(
                f"<path d='{d}' fill='{color}'></path>"
            )
            current += sweep

        legend_items = []
        # Add total count item first
        legend_items.append(
          f"<div class='legend-item'><span class='key' style='background:#6b7280'></span>総数: {total_count}</div>"
        )
        for label, value, color in segments:
          legend_items.append(
            f"<div class='legend-item'><span class='key' style='background:{color}'></span>{html.escape(label)}: {value}</div>"
          )

        return (
            "<div class='pie'>"
            "<svg class='pie-chart' viewBox='0 0 200 200' width='200' height='200'>"
            + "".join(svg_paths) +
            "</svg>"
            + "<div class='legend'>" + "".join(legend_items) + "</div>"
            "</div>"
        )

    rows = []
    for c in cases:
      test_type, test_case = split_name(c.get('name') or '')
      # Build collapsible logs section if any output exists
      has_stdout = bool(c.get('stdout'))
      has_stderr = bool(c.get('stderr'))
      logs_html = ""
      if has_stdout or has_stderr:
        parts = []
        if has_stdout:
          parts.append(
            "<div><b>Stdout</b></div>" +
            f"<pre>{html.escape(c['stdout'])}</pre>"
          )
        if has_stderr:
          parts.append(
            "<div><b>Stderr</b></div>" +
            f"<pre>{html.escape(c['stderr'])}</pre>"
          )
        logs_html = (
          "<details class=\"logs\">"
          "<summary>ログを表示</summary>"
          + "".join(parts) +
          "</details>"
        )

      detail_text = html.escape(c['details'])
      # If there is neither details nor logs, show '-'
      if (not detail_text) and (not logs_html):
        detail_cell = "-"
      else:
        detail_cell = detail_text + ("<br>" + logs_html if logs_html else "")

      rows.append(
        f"<tr class='row-{c['outcome']}'>"
        f"<td>{html.escape(test_type)}</td>"
        f"<td>{html.escape(test_case)}</td>"
        f"<td>{c['time']:.3f} s</td>"
        f"<td class='{c['outcome']}'>{c['outcome'].capitalize()}</td>"
        f"<td>{detail_cell}</td>"
        f"</tr>"
      )

    return f"""
<!DOCTYPE html>
<html lang=\"ja\">
<head>
<meta charset=\"UTF-8\">
<title>{html.escape(title)}</title>
<style>
body {{ font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, 'Hiragino Kaku Gothic ProN', 'Noto Sans JP', 'Yu Gothic', Meiryo, sans-serif; margin: 0; background: #fafafa; color: #222; }}
header {{ background: #007acc; color: #fff; padding: 12px 16px; }}
main {{ padding: 16px; }}
.container {{ max-width: 1100px; margin: 0 auto; }}
.cards {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin: 12px 0 20px; }}
.card {{ background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 12px; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }}
.card h3 {{ margin: 6px 0 10px; font-size: 20px; color: #374151; }}
.card .desc {{ font-size: 16px; color: #374151; line-height: 1.6; }}
.card .result {{ font-size: 28px; font-weight: 700; margin-top: 6px; }}
.card .muted {{ color: #6b7280; font-size: 12px; }}
.card .good {{ color: #059669; }}
.card .warn {{ color: #d97706; }}
.card .bad {{ color: #dc2626; }}
.summary {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 8px; margin-top: 8px; }}
.summary .pill {{ background: #f3f4f6; border-radius: 999px; padding: 8px 10px; font-size: 13px; text-align: center; }}
.table {{ width: 100%; border-collapse: collapse; background: #fff; border: 1px solid #e5e7eb; overflow: hidden; border-radius: 8px; table-layout: fixed; }}
.table th, .table td {{ padding: 8px 10px; border-bottom: 1px solid #e5e7eb; word-break: break-word; }}
.table th {{ background: #f9fafb; text-align: left; font-weight: 600; color: #374151; }}
.table td {{ vertical-align: top; }}
/* Column widths: 1)種別 2)ケース 3)時間 4)結果 5)エラーログ */
.table th:nth-child(1), .table td:nth-child(1) {{ width: 16%; }}
.table th:nth-child(2), .table td:nth-child(2) {{ width: 28%; }}
.table th:nth-child(3), .table td:nth-child(3) {{ width: 12%; }}
.table th:nth-child(4), .table td:nth-child(4) {{ width: 12%; }}
.table th:nth-child(5), .table td:nth-child(5) {{ width: 32%; }}
.table tr:last-child td {{ border-bottom: none; }}
.right {{ text-align: right; }}
.center {{ text-align: center; }}
.passed {{ color: #065f46; }}
.failed {{ color: #b91c1c; }}
.skipped {{ color: #92400e; }}
.row-failed {{ background: #fff1f2; }}
.footer {{ color: #6b7280; font-size: 12px; margin-top: 12px; text-align: right; }}
.logs summary {{ cursor: pointer; color: #2563eb; }}
.logs {{ margin-top: 6px; max-width: 100%; }}
.logs pre {{ background: #1e1e1e; color: #cbd5e1; padding: 8px; border-radius: 6px; overflow-x: auto; overflow-y: auto; max-width: 100%; max-height: 260px; white-space: pre; }}
.pie {{ display: grid; grid-template-columns: auto; justify-items: center; gap: 6px; }}
.pie-chart {{ display: block; width: 180px; height: 180px; }}
.legend {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 6px; margin-top: 4px; }}
.legend-item {{ font-size: 13px; color: #374151; }}
.legend-item .key {{ display: inline-block; width: 12px; height: 12px; border-radius: 2px; margin-right: 6px; vertical-align: middle; }}
</style>
</head>
<body>
<header>
  <div class='container'>
    <h1>テストレポート:{html.escape(title)}</h1>
    <div class='muted'>生成時刻: {now}</div>
  </div>
</header>
<main>
  <div class='container'>
    <div class='cards'>
      <div class='card'>
        <h3>総実行時間</h3>
        <div class='desc'>各テストケースの合計</div>
        <div class='result'>{total_time:.3f} 秒</div>
      </div>
      <div class='card'>
        <h3>成功率</h3>
        <div class='desc'>成功 {passed} / 実行数 {executed}</div>
        <div class='result {pct_class(success_rate)}'>{success_rate:.2f}%</div>
      </div>
      
      <div class='card'>
        <h3>内訳グラフ</h3>
        {pie_svg(passed, failures + errors, skipped, tests)}
      </div>
    </div>

    <table class='table'>
      <thead>
        <tr>
          <th>テスト種別</th>
          <th>テストケース</th>
          <th>時間</th>
          <th>結果</th>
          <th>エラーログ</th>
        </tr>
      </thead>
      <tbody>
        {''.join(rows)}
      </tbody>
    </table>

    <div class='footer'>Generated from JUnit XML</div>
  </div>
</main>
</body>
</html>
"""


def main() -> int:
    args = parse_args()
    xml_path = args.xml
    if not os.path.exists(xml_path):
        print(f"XML not found: {xml_path}", file=sys.stderr)
        return 2

    tests, failures, errors, skipped, total_time, cases = collect_tests(xml_path)

    base = os.path.basename(xml_path)
    # Format display title: prefer trailing YYYYMMDD_HHMMSS if present, else basename without extension
    title = format_display_title(base)
    html_text = render_html(title, tests, failures, errors, skipped, total_time, cases)

    out = args.out or os.path.join(os.path.dirname(xml_path), os.path.splitext(base)[0] + "_with_summary.html")
    with open(out, "w", encoding="utf-8") as f:
        f.write(html_text)

    print(f"Wrote: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
