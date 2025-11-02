# Northwind Data Analysis Project

This repository contains a comprehensive analysis of the Northwind database, a sample database commonly used for learning and demonstration purposes. The project includes both SQL and Python-based analyses of the business data.

## Project Structure

```
├── dataset/               # CSV files containing Northwind database tables
├── medmnist_data/        # Medical MNIST dataset
├── pythonAnalysis/       # Jupyter notebooks for Python-based analysis
└── sqlAnalysis/          # SQL queries and analysis
```

## Datasets

### Northwind Dataset
The dataset/ directory contains the following CSV files from the Northwind database:
- `categories.csv` - Product categories
- `customers.csv` - Customer information
- `employee_territory.csv` - Employee territory assignments
- `employees.csv` - Employee information
- `order_details.csv` - Detailed order information
- `orders.csv` - Order header information
- `products.csv` - Product information
- `region.csv` - Sales regions
- `shippers.csv` - Shipping company information
- `suppliers.csv` - Supplier information
- `territories.csv` - Sales territories

### Medical MNIST Dataset
The medmnist_data/ directory contains:
- `dermamnist.npz` - Dermatology image dataset

## Analysis Components

### Python Analysis
Located in the `pythonAnalysis/` directory:
- `northwind.ipynb` - Primary Northwind data analysis notebook
- `northwind2.ipynb` - Additional analysis and visualizations
- `porject.ipynb` - Project-specific analysis

### SQL Analysis
Located in the `sqlAnalysis/` directory:
- `Northwind.sql` - SQL queries and database analysis

## Getting Started

1. Clone this repository
2. Ensure you have the following prerequisites installed:
   - Python 3.x
   - Jupyter Notebook
   - Required Python packages (pandas, numpy, matplotlib, etc.)
   - A SQL database management system (for SQL analysis)

## Usage

### For Python Analysis:
1. Navigate to the `pythonAnalysis/` directory
2. Launch Jupyter Notebook
3. Open any of the .ipynb files to view or run the analysis

### For SQL Analysis:
1. Set up a SQL database
2. Import the Northwind database
3. Use the queries in `Northwind.sql` to perform analysis

## Contributing

Feel free to fork this repository and submit pull requests with improvements or additional analyses.

## License

This project uses the Northwind database, which is a sample database created by Microsoft for educational purposes.

## Author

RookieCoder12