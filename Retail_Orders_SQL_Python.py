import os
import zipfile
import logging
import pandas as pd

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def download_and_extract_kaggle_dataset():
    """Downloads and extracts the retail orders dataset from Kaggle."""
    try:
        logging.info("Downloading dataset from Kaggle...")
        os.system("kaggle datasets download ankitbansal06/retail-orders -f orders.csv --force")
        
        logging.info("Extracting dataset...")
        with zipfile.ZipFile('orders.csv.zip', 'r') as zip_ref:
            zip_ref.extractall()
        logging.info("Dataset extracted successfully.")
    except Exception as e:
        logging.error(f"Error in downloading or extracting dataset: {e}")

def load_and_process_data(file_path):
    """Loads data into a Pandas DataFrame, handles null values, and renames columns."""
    try:
        logging.info("Loading dataset into DataFrame...")
        df = pd.read_csv(file_path, na_values=['Not Available', 'unknown'])
        
        logging.info("Cleaning column names...")
        df.rename(columns=lambda x: x.lower().replace(' ', '_'), inplace=True)
        
        logging.info("Dataset loaded and processed successfully.")
        return df
    except Exception as e:
        logging.error(f"Error in loading dataset: {e}")
        return None

def main():
    """Main function to execute the script."""
    dataset_file = 'orders.csv'
    download_and_extract_kaggle_dataset()
    df = load_and_process_data(dataset_file)
    
    if df is not None:
        logging.info("Displaying first 5 rows of the dataset:")
        print(df.head())

if __name__ == "__main__":
    main()
