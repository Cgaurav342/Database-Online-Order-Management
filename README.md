# Database Project - PostgreSQL

This project contains a PostgreSQL database schema and sample data loading process.

## 📂 Project Structure
- `create.sql` → Creates the database schema (tables, relationships, constraints).
- `load.sql` → Loads CSV data into the database using PostgreSQL `COPY` commands.
- `data/` → Folder containing CSV files to be loaded.

## 🛠️ Setup Instructions

1. **Create Database**
   ```bash
   psql -U <username> -d <database_name> -f create.sql

2. **Load Data**
   ```bash
    psql -U <username> -d <database_name> -f load.sql
