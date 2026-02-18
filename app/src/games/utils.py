from openpyxl import load_workbook


def get_games_from_xlsx(file_path: str):
    # Load the Excel workbook from the given file path
    workbook = load_workbook(filename=file_path)

    # Select the active sheet (first sheet by default)
    sheet = workbook.active

    # Read the header row (first row) to get column names
    headers = [cell.value for cell in sheet[1]]

    # Initialize an empty list to store game dictionaries
    games = []

    # Iterate over rows starting from the second row (skip headers)
    # Use values_only=False to get Cell objects instead of already processed values
    for row in sheet.iter_rows(min_row=2, values_only=False):
        row_data = {}

        # Map each header to the corresponding cell value
        for header, cell in zip(headers, row, strict=False):
            # Convert cell value to string to prevent Excel auto-formatting issues
            # (e.g., "2-10" being converted to a date)
            # If the cell is empty (None), use an empty string
            row_data[header] = str(cell.value) if cell.value is not None else ""

        # Create a dictionary for each game using the desired columns
        games.append(
            {
                "name": row_data.get("Name"),
                "players": row_data.get("Number of players"),
                "time": row_data.get("Average game time [h:mm]"),
                "description": row_data.get("Category"),
                "image_url": row_data.get("Image URL", ""),
            }
        )

    # Return the list of game dictionaries
    return games
