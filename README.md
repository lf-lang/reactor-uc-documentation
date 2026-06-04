# reactor-uc Documentation

Source for the [micro-LF](https://micro-lf.org) documentation website, built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

## Local Development

### Prerequisites

You need Python 3 and pip, or [Nix](https://nixos.org/).

### Option 1: pip (virtual environment)

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Then start the live-reloading development server:

```bash
mkdocs serve
```

The site will be available at [http://127.0.0.1:8000](http://127.0.0.1:8000). MkDocs watches for file changes and automatically reloads the browser.

### Option 2: Nix

If you have Nix with flakes enabled:

```bash
nix develop
mkdocs serve
```

Or using the legacy `shell.nix`:

```bash
nix-shell
mkdocs serve
```

## Building the Static Site

To generate the static site output into the `site/` directory:

```bash
mkdocs build
```

## Project Structure

```
docs/        # Markdown source files
mkdocs.yaml  # MkDocs configuration
requirements.txt  # Python dependencies
site/        # Generated static site output (not committed)
```

## Contributing

Edit the Markdown files under `docs/` and use `mkdocs serve` to preview changes locally before submitting a pull request. The upstream repository is [lf-lang/reactor-uc](https://github.com/lf-lang/reactor-uc).
