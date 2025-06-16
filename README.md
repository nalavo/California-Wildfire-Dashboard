# California Crash Dashboard

This is a Shiny dashboard app built in R that visualizes crash data in California from 2014 to 2023.

🔗 **Live App**: [https://nalavo.shinyapps.io/APP3/](https://nalavo.shinyapps.io/APP3/)

---

## 📊 Features

- Interactive data exploration of traffic crashes in California.
- Built-in CSV data (`crashes_california_2014_2023.csv`).
- Clean interface and fast loading with Shiny.

---

## 📁 Files

- `app.R`: Main Shiny app file.
- `crashes_california_2014_2023.csv`: Traffic crash dataset.
- `manifest.json`: App metadata for deployment.

---

## 🚀 Running the App Locally

1. Install [R](https://cran.r-project.org/) and [RStudio](https://posit.co/download/rstudio/).
2. Open `app.R` in RStudio.
3. Click **Run App** or run:
   ```r
   shiny::runApp()
   ```

---

## 📦 Required R Packages

Make sure these packages are installed:

```r
install.packages(c("shiny", "tidyverse", "ggplot2", "readr"))
```

---

## 🎨 Stylesheet Note

The main CSS file (`style.css`) is **not included in this repository** due to GitHub’s 100MB file size limit.

You can still run the app by either:

1. **Using a local version**:
   - Place `style.css` in the app folder.
   - Ensure your HTML or Shiny app points to it correctly.

2. **Using a hosted version**:
   ```html
   <link rel="stylesheet" href="https://your-cdn-link.com/style.css">
   ```

> 🔹 If you need the file, please [contact the author](mailto:your.email@example.com) or upload it manually.

---

## 🗺️ Data Source

Crash data collected across California from 2014 to 2023.

---

## 📄 License

MIT License
