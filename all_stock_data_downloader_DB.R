# Load required packages
#install.packages("pacman")

pacman::p_load(
  DBI,
  RSQLite,
  tidyquant,
  dplyr,
  tibble,
  progress,
  fs,
  furrr
)

# List of target databases
# target_DB can be obtained from my repository "python code for finance / tickers DB folder "
## tickers DB folder: https://github.com/parkminhyung/python-code-for-finance/tree/main/tickers%20DB
# Download DB.csv files and modify path like db_dir

# target_DB list
target_DBs = c("KRX_DB", "IND_DB", "JPX_DB", "HK_DB", "SSE_DB","US_DB")

# Set the database file path
db_dir <- "your own path where DB file saved"
db_path = file.path(db_dir, "STOCK_DB.db") #database path

# Create directory if it does not exist
if (!dir_exists(db_dir)) {
  dir_create(db_dir)
  cat("Directory created:", db_dir, "\n")
}

# Connect to the SQLite database (automatically created if it does not exist)
conn = dbConnect(RSQLite::SQLite(), dbname = db_path)
cat("Database connected: ", db_path, "\n")

# Update data for each target database table
for (target_DB in target_DBs) {
  cat("\nProcessing target database:", target_DB, "\n")
  
  # Set the database table name
  table_name = target_DB
  
  # Check if the table exists
  if (!(table_name %in% dbListTables(conn))) {
    cat("No existing table found for", target_DB, ". Creating new table.\n")
    dbExecute(conn, paste0("
      CREATE TABLE ", table_name, " (
        ticker TEXT,
        date TEXT,
        open REAL,
        high REAL,
        low REAL,
        close REAL,
        volume INTEGER
      )
    "))
    last_date = Sys.Date() - months(6) 
  } else {
    # Check the last date in the existing table
    last_date_query = paste("SELECT MAX(date) AS last_date FROM", table_name)
    last_date = dbGetQuery(conn, last_date_query)$last_date
    last_date = as.Date(last_date, format = "%Y-%m-%d")
    cat("Last data date in", target_DB, "DB:", last_date, "\n")
    
    #if last date is the same as today date, skip update
    if (last_date == Sys.Date()) {
      cat("Data in", target_DB, "is already up-to-date. Skipping.\n")
      next
    }
  }
  
  # Set the date range for updating
  start_date = last_date + 1
  end_date = Sys.Date()
  
  #Load the list of tickers 
  ticker_file <- paste0("your own path where DB csv file stored", target_DB, ".csv") ## DB csv file is : KRX_DB.csv, SSE_DB.csv ... etc 
  
  if (!file.exists(ticker_file)) {
    cat("Ticker file not found for", target_DB, ". Skipping.\n")
    next
  }
  tickers = read.csv(ticker_file) %>% pull(tickers)
  
  # Set data download: parallel processing and chunked download
  chunk_size = 100 # Chunk size
  chunks = split(tickers, ceiling(seq_along(tickers) / chunk_size))
  
  cat("Downloading data from", as.Date(start_date), "to", as.Date(end_date), "for", target_DB, "\n")
  
  # Set progress bar for tracking progress
  pb = progress_bar$new(
    format = paste0(target_DB, " [:bar] :percent | ETA: :eta"),
    total = length(chunks), clear = FALSE, width = 80
  )
  
  # Configure parallel processing
  plan(multisession, workers = parallel::detectCores() - 1) 
  
  # Download data using parallel processing
  stock_data = future_map(chunks, function(ticker_chunk) {
    tryCatch({
      tq_get(
        ticker_chunk,
        from = start_date,
        to = end_date,
        get = "stock.prices"
      )
    }, error = function(e) {
      cat("Error in chunk:", e$message, "\n")
      return(NULL)
    })
  }, .progress = TRUE)
  
  stock_data = bind_rows(stock_data)
  
  # binding data
  if (nrow(stock_data) == 0) {
    cat("No data downloaded for", target_DB, ". Skipping update.\n")
    next
  }
  
  # Check columns of data
  required_cols = c("symbol", "date", "open", "high", "low", "adjusted", "volume")
  missing_cols = setdiff(required_cols, colnames(stock_data))
  if (length(missing_cols) > 0) {
    stop("Missing columns in downloaded data: ", paste(missing_cols, collapse = ", "))
  }
  
  # Data selection and modify the name of columns
  stock_data = stock_data %>%
    select(symbol, date, open, high, low, adjusted, volume) %>%
    rename(
      ticker = symbol,
      close = adjusted
    ) %>%
    mutate(date = as.character(date)) 
  
  # add data frame to DB
  if (nrow(stock_data) > 0) {
    dbWriteTable(conn, table_name, stock_data, append = TRUE, row.names = FALSE)
    cat("\nData updated successfully in", target_DB, ".\n")
  } else {
    cat("\nNo new data found for", target_DB, ".\n")
  }
  
  # update Progress bar 
  pb$tick()
}

# disconnect DB 
dbDisconnect(conn)
cat("\nDatabase connection closed. All updates completed for all target databases.\n")




## if you want to update automatically on a regular basis, (MAC or Linux)
## you can use "crontab -e" via terminal and edit vim 
## Also, you can run this code via this code on your own terminal : $ Rscipt all_stock_data_downloader_DB.R


