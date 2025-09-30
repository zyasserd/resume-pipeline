#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.pymupdf

"""
This script extracts hyperlinks and their corresponding text from a given PDF file.
It highlights the differences between the extracted text and the actual hyperlink,
indicating any missing parts when the PDF is flattened and links are removed.
Outputs a simple HTML page.
"""


import sys
import difflib
import fitz  # PyMuPDF
from jinja2 import Template


HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PDF Link Extraction</title>
    <style>
        body { font-family: sans-serif; }
        li { margin-bottom: 1em; }
        .lost {
            background-color: #ffe5e5;   /* Soft red/pink background */
            color: #b71c1c;              /* Deep red text */
            border-radius: 4px;
            # padding: 0 5px;
            font-weight: 600;
        }
        .url { font-family: monospace; }
    </style>
</head>
<body>
    <h2>Potential data loss in the PDF when flattened</h2>
    <p>The following is a list of links within the PDF. The highlighted text is the lost information when the PDF is flattened and the links are removed.<br>
    This helps you identify if any crucial details are missing, which might be overlooked by an ATS or become inactive when printed.</p>
    <ul>
    {% for link in processed_links %}
        <li>{{ link | safe }}</li>
    {% endfor %}
    </ul>
</body>
</html>
"""


class RangeSet:
    """
    Maintains a sorted, non-overlapping set of ranges.
    Used to efficiently track which character indices in a string are 'covered'.
    """
    def __init__(self):
        self.ranges = []  # list of range objects

    def add(self, new: range):
        """
        Add a new range, merging with any overlapping or adjacent ranges.
        """
        new_start, new_stop = new.start, new.stop
        merged = []
        placed = False

        for r in self.ranges:
            start, stop = r.start, r.stop

            if new_stop < start:  
                # new goes completely before
                if not placed:
                    merged.append(range(new_start, new_stop))
                    placed = True
                merged.append(r)
            elif new_start > stop:  
                # new goes completely after
                merged.append(r)
            else:  
                # overlap, merge into new
                new_start = min(new_start, start)
                new_stop = max(new_stop, stop)

        if not placed:
            merged.append(range(new_start, new_stop))

        self.ranges = merged

    def __repr__(self):
        return "[" + ", ".join(f"range({r.start}, {r.stop})" for r in self.ranges) + "]"


def color_text(text, color=None):
    """
    Wraps the given text in a <span> with the 'lost' class for highlighting.
    If color is None, returns the text as-is.
    """
    if color:
        return f'<span class="lost">{text}</span>'
    else:
        return text


def find_missing_parts(link, extracted_texts):
    """
    Given a link and a list of extracted texts, highlight the parts of the link
    that have never appeared in any of the extracted_texts, using difflib for matching.

    Args:
        link (str): The full URL or link string.
        extracted_texts (Iterable[str]): All visible texts extracted from the PDF for this link.

    Returns:
        str: The link with missing parts wrapped in a <span class="lost"> for HTML highlighting.
    """
    covered = RangeSet()
    for text in extracted_texts:
        # Use difflib to find matching (equal) spans between the link and each extracted text
        matcher = difflib.SequenceMatcher(None, link, text)
        for tag, i1, i2, _, _ in matcher.get_opcodes():
            if tag == "equal":
                covered.add(range(i1, i2))

    # Build the highlighted output using covered ranges
    result = ""
    last = 0
    for r in sorted(covered.ranges, key=lambda r: r.start):
        # Highlight missing part before this covered range
        if last < r.start:
            result += color_text(link[last:r.start], "red")
        # Add covered part (visible in PDF)
        result += link[r.start:r.stop]
        last = r.stop
    # Highlight any remaining missing part at the end
    if last < len(link):
        result += color_text(link[last:], "red")
    return result


def extract_links_and_text(pdf_file):
    """
    Extracts all hyperlinks and their corresponding visible text from a PDF file.

    Args:
        pdf_file (str): Path to the PDF file.

    Returns:
        list[dict]: List of dicts with 'uri' and 'text' keys for each link found.
    """
    with fitz.open(pdf_file) as document:
        links_and_text = []
        for page_num in range(len(document)):
            page = document[page_num]
            links = page.get_links()
            for link in links:
                uri = link["uri"]
                if uri:
                    text_within_rect = page.get_textbox(link["from"])
                    links_and_text.append({"uri": uri, "text": text_within_rect})
    return links_and_text


if __name__ == "__main__":
    # Entry point: expects a single PDF file as argument
    if len(sys.argv) != 2:
        print("Usage: ./extract_pdf_links.py <pdf_file>")
        sys.exit(1)

    pdf_file = sys.argv[1]
    links_and_text = extract_links_and_text(pdf_file)

    # Group all extracted texts by their associated URI
    groups = {}
    for item in links_and_text:
        uri = item["uri"]
        if uri not in groups:
            groups[uri] = set()
        groups[uri].add(item['text'].strip())

    # For each URI, determine which parts would be lost if the PDF is flattened
    processed_links = []
    for (uri, texts) in groups.items():
        processed_links.append(find_missing_parts(uri, texts))

    # Render HTML using the template string
    template = Template(HTML_TEMPLATE)
    html_output = template.render(processed_links=processed_links)

    # Output the result to stdout
    print(html_output)
