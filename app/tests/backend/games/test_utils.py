from types import SimpleNamespace
from unittest.mock import MagicMock, Mock, patch

from games.utils import get_games_from_xlsx


def _cell(value):
    """Helper function to simulate openpyxl cell objects."""
    return SimpleNamespace(value=value)


@patch("games.utils.load_workbook")
def test_get_games_from_xlsx_returns_expected_data(mock_load_workbook):
    """This test verifies that:
    - The Excel workbook is loaded correctly.
    - Headers are mapped to row values accurately.
    - The function returns a list of dictionaries with the expected structure.
    """
    # Mock sheet object
    mock_sheet = MagicMock()

    # Define headers
    mock_sheet.__getitem__.return_value = [
        _cell("Name"),
        _cell("Number of players"),
        _cell("Average game time [h:mm]"),
        _cell("Category"),
        _cell("Image URL"),
    ]

    # Define rows of data
    mock_sheet.iter_rows.return_value = [
        (
            _cell("Catan"),
            _cell("3-4"),
            _cell("1:00"),
            _cell("Strategy"),
            _cell("https://example.com/catan.jpg"),
        ),
        (
            _cell("Monopoly"),
            _cell("2-6"),
            _cell("2:00"),
            _cell("Family"),
            _cell("https://example.com/monopoly.jpg"),
        ),
    ]

    # Mock workbook object
    mock_workbook = Mock()
    mock_workbook.active = mock_sheet

    mock_load_workbook.return_value = mock_workbook

    expected_result = [
        {
            "name": "Catan",
            "players": "3-4",
            "time": "1:00",
            "description": "Strategy",
            "image_url": "https://example.com/catan.jpg",
        },
        {
            "name": "Monopoly",
            "players": "2-6",
            "time": "2:00",
            "description": "Family",
            "image_url": "https://example.com/monopoly.jpg",
        },
    ]

    result = get_games_from_xlsx("dummy_path.xlsx")

    # Check if workbook was loaded with the correct file path
    mock_load_workbook.assert_called_once_with(filename="dummy_path.xlsx")
    # Check if iter_rows was called with the correct parameters
    mock_sheet.iter_rows.assert_called_once_with(min_row=2, values_only=False)
    # Assert the result matches the expected output
    assert result == expected_result


@patch("games.utils.load_workbook")
def test_get_games_from_xlsx_missing_column(mock_load_workbook):
    """This test checks how the function handles missing columns in the Excel sheet.
    It verifies that:
    - The function does not raise an error when expected columns are missing.
    - The returned dictionaries contain None for missing columns.
    """
    # Mock sheet object with missing 'Category' column
    mock_sheet = MagicMock()
    mock_sheet.__getitem__.return_value = [
        _cell("Name"),
        _cell("Number of players"),
        _cell("Average game time [h:mm]"),
        _cell("Category"),
    ]

    # Define rows of data
    mock_sheet.iter_rows.return_value = [
        (_cell("Catan"), _cell("3-4"), _cell("1:00"), _cell("Strategy")),
    ]

    # Mock workbook object
    mock_workbook = Mock()
    mock_workbook.active = mock_sheet

    mock_load_workbook.return_value = mock_workbook

    expected_result = [
        {
            "name": "Catan",
            "players": "3-4",
            "time": "1:00",
            "description": "Strategy",
            "image_url": "",  # Missing column should result in None
        },
    ]

    result = get_games_from_xlsx("dummy_path.xlsx")

    # Check if workbook was loaded with the correct file path
    mock_load_workbook.assert_called_once_with(filename="dummy_path.xlsx")
    # Check if iter_rows was called with the correct parameters
    mock_sheet.iter_rows.assert_called_once_with(min_row=2, values_only=False)
    # Assert the result matches the expected output with None for missing columns
    assert result == expected_result


@patch("games.utils.load_workbook")
def test_get_games_from_xlsx_empty_sheet(mock_load_workbook):
    """This test verifies that the function can handle an empty Excel sheet gracefully.
    It checks that:
    - The function returns an empty list when there are no data rows.
    - The function does not raise an error when the sheet is empty.
    """
    # Mock sheet object with only headers and no data rows
    mock_sheet = MagicMock()
    mock_sheet.__getitem__.return_value = [
        _cell("Name"),
        _cell("Number of players"),
        _cell("Average game time [h:mm]"),
        _cell("Category"),
    ]

    # No data rows
    mock_sheet.iter_rows.return_value = []

    # Mock workbook object
    mock_workbook = Mock()
    mock_workbook.active = mock_sheet

    mock_load_workbook.return_value = mock_workbook

    expected_result = []

    result = get_games_from_xlsx("dummy_path.xlsx")

    # Check if workbook was loaded with the correct file path
    mock_load_workbook.assert_called_once_with(filename="dummy_path.xlsx")
    # Check if iter_rows was called with the correct parameters
    mock_sheet.iter_rows.assert_called_once_with(min_row=2, values_only=False)
    # Assert the result is an empty list
    assert result == expected_result
