import pandas as pd
import pyodbc
import logging
import smtplib
from email.message import EmailMessage


# -----------------------------
# Logging configuration
# -----------------------------
logging.basicConfig(
    filename=r"C:\sql practice\project\Marketing analysis\Marketing_Automation\automation_log.txt",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

try:
    # -----------------------------
    # 1. SQL Server connection
    # -----------------------------
    conn = pyodbc.connect(
        "DRIVER={SQL Server};"
        "SERVER=LAPTOP-7GGQ7OAS\\SQLEXPRESS;"
        "DATABASE=PracticeDB;"
        "Trusted_Connection=yes;"
    )

    # -----------------------------
    # 2. Read data from SQL
    # -----------------------------
    df = pd.read_sql("SELECT * FROM marketing", conn)
    conn.close()

    logging.info("Marketing data read successfully from SQL Server")
    print("Data loaded from SQL successfully")

    # -----------------------------
    # 3. Data quality checks
    # -----------------------------
    print("\nMissing values per column:")
    print(df.isnull().sum())

    # -----------------------------
    # 4. KPI Calculations
    # -----------------------------
    total_sales = df['sales'].sum()

    df['total_spend'] = df['tv'] + df['radio'] + df['social_media']
    total_spend = df['total_spend'].sum()

    avg_sales = df['sales'].mean()
    roi = (total_sales - total_spend) / total_spend

    # -----------------------------
    # 5. KPI Output
    # -----------------------------
    print("\n--- KPI VALUES ---")
    print("Total Sales:", round(total_sales, 2))
    print("Total Marketing Spend:", round(total_spend, 2))
    print("Average Sales:", round(avg_sales, 2))
    print("ROI:", round(roi, 4))

    # -----------------------------
    # 6. KPI Summary Table
    # -----------------------------
    kpi_df = pd.DataFrame({
        "Metric": [
            "Total Sales",
            "Total Marketing Spend",
            "Average Sales",
            "TV Spend",
            "Radio Spend",
            "Social Media Spend",
            "ROI"
        ],
        "Value": [
            round(total_sales, 2),
            round(total_spend, 2),
            round(avg_sales, 2),
            round(df['tv'].sum(), 2),
            round(df['radio'].sum(), 2),
            round(df['social_media'].sum(), 2),
            round(roi, 4)
        ]
    })

    print("\nKPI Summary Table")
    print(kpi_df)

    # -----------------------------
    # 7. Export KPIs
    # -----------------------------
    kpi_df.to_csv("marketing_kpi_summary.csv", index=False)
    logging.info("KPI CSV created successfully")
    print("KPI CSV created successfully")

    # -----------------------------
    # 8. Email Alert if Sales Drop
    # -----------------------------
    ALERT_THRESHOLD = avg_sales * 0.8

    if total_sales < ALERT_THRESHOLD:
        msg = EmailMessage()
        msg.set_content(
            f"""
            ALERT: Sales Drop Detected

            Total Sales: {round(total_sales, 2)}
            Threshold: {round(ALERT_THRESHOLD, 2)}

            Please review the marketing performance.
            """
        )

        msg["Subject"] = "🚨 Marketing Sales Alert"
        msg["From"] = "sahasrabudhekartikeya@outlook.com"
        msg["To"] = "sahasrabudhekartikeya@outlook.com"

        with smtplib.SMTP("smtp.office365.com", 587) as server:
            server.starttls()
            server.login("sahasrabudhekartikeya@outlook.com", "YOUR_PASSWORD")
            server.send_message(msg)


        logging.warning("Sales alert email sent")
        print("Sales alert email sent")


    logging.info("Automation script completed successfully")

    from openpyxl import load_workbook

    excel_path = r"C:\sql practice\project\Marketing analysis\Marketing_Automation\marketing_kpi_report.xlsx"

    # Export to Excel
    kpi_df.to_excel(excel_path, index=False)

    # Format Excel
    wb = load_workbook(excel_path)
    ws = wb.active

    # Bold headers
    for cell in ws[1]:
        cell.font = cell.font.copy(bold=True)

    # Auto-adjust column width
    for column in ws.columns:
        max_length = 0
        col_letter = column[0].column_letter
        for cell in column:
            if cell.value:
                max_length = max(max_length, len(str(cell.value)))
        ws.column_dimensions[col_letter].width = max_length + 3

    wb.save(excel_path)

    logging.info("Excel KPI report generated successfully")
    print("Excel KPI report generated successfully")


except Exception as e:
    logging.error(f"Automation failed: {e}")
    print("Automation failed. Check automation_log.txt")
    raise
