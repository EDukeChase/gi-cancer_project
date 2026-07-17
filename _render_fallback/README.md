# Local Render Fallback

If a rendered `.html` doc lands in this folder, `QUARTO_PROFILE` wasn't set (or didn't match `laptop`/`desktop`) for that render, so Quarto used this local fallback instead of writing to OneDrive.

Check `.Renviron` against `.Renviron.example` at the project root, restart R, and re-render.
