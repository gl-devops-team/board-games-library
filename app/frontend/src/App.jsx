/**
 * Main application component.
 *
 * Fetches board games from backend API and displays them
 * in a searchable and sortable table.
 *
 * Features:
 * - Fetch data from backend on mount
 * - Filter games by name
 * - Sort games by selected column
 *
 * @component
 */
import './App.css'
import { useEffect, useState } from "react";

function App() {

  /**
   * State: list of games fetched from backend API.
   * @type {[Array, Function]}
   */
  const [games, setGames] = useState([]);

  /**
   * State: search query entered by user.
   * Used for filtering games by name.
   * @type {[string, Function]}
   */
  const [search, setSearch] = useState("");

  /**
   * State: configuration object for sorting.
   * Contains:
   * - key: property name to sort by
   * - direction: "asc" | "desc"
   *
   * @type {[{key: string, direction: string} | null, Function]}
   */
  const [sortConfig, setSortConfig] = useState(null);

  /**
   * Fetch games from backend API when component mounts.
   *
   * Endpoint:
   * http://localhost:8000/api/games/
   *
   * On success:
   * - Stores received data in `games` state.
   *
   * On failure:
   * - Logs error to console.
   */
  useEffect(() => {
    fetch("http://localhost:8000/api/games/")
      .then(res => res.json())
      .then(data => {
        console.log("DATA:", data);
        setGames(data);
      })
      .catch(err => console.error("BŁĄD:", err));
  }, []);

  /**
   * Filters games based on the current search query.
   *
   * Case-insensitive comparison on the `name` property.
   *
   * @type {Array}
   */
  const filteredGames = games.filter(game =>
    game.name.toLowerCase().includes(search.toLowerCase())
  );

  /**
   * Sorts filtered games based on current sort configuration.
   *
   * Sorting behavior:
   * - If no sortConfig → no sorting applied
   * - Sorts ascending or descending
   *
   * @type {Array}
   */
  const sortedGames = [...filteredGames].sort((firstGame, secondGame) => {
    if (!sortConfig) return 0;

    const { key, direction } = sortConfig;

    if (firstGame[key] < secondGame[key]) return direction === "asc" ? -1 : 1;
    if (firstGame[key] > secondGame[key]) return direction === "asc" ? 1 : -1;

    return 0;
  });

  /**
   * Updates sorting configuration.
   *
   * If the same column is clicked twice,
   * sorting direction toggles between ascending and descending.
   *
   * @param {string} key - Object property to sort by
   */
  const handleSort = (key) => {
    setSortConfig({
      key,
      direction:
        sortConfig?.key === key && sortConfig.direction === "asc"
          ? "desc"
          : "asc"
    });
  };

  return (
    <div className="container">
      <h1>Lista gier planszowych</h1>

      {/* Search input field */}
      <input
        type="text"
        placeholder="Szukaj gry po nazwie..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

      {/* Games table */}
      <table>
        <thead>
          <tr>
            <th onClick={() => handleSort("name")}>Nazwa ▲▼</th>
            <th onClick={() => handleSort("players")}>Liczba graczy ▲▼</th>
            <th onClick={() => handleSort("time")}>Czas gry ▲▼</th>
            <th onClick={() => handleSort("description")}>Kategoria ▲▼</th>
          </tr>
        </thead>
        <tbody>
          {sortedGames.length > 0 ? (
            sortedGames.map((game, index) => (
              <tr key={index}>
                <td>{game.name}</td>
                <td>{game.players}</td>
                <td>{game.time}</td>
                <td>{game.description}</td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="4">Brak gier do wyświetlenia</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

/**
 * Export main App component.
 */
export default App;