import './App.css'
import { useEffect, useState } from "react";

function App() {
  const [games, setGames] = useState([]);
  const [search, setSearch] = useState("");
  const [sortConfig, setSortConfig] = useState(null);

  useEffect(() => {
    fetch("http://localhost:8000/api/games/")
      .then(res => res.json())
      .then(data => {
        console.log("DATA:", data);
        setGames(data);
      })
      .catch(err => console.error("BŁĄD:", err));
  }, []);

  // Filter function
  const filteredGames = games.filter(game =>
    game.name.toLowerCase().includes(search.toLowerCase())
  );

  // Sorting function
  const sortedGames = [...filteredGames].sort((firstGame, secondGame) => {
    if (!sortConfig) return 0;

    const { key, direction } = sortConfig;
    if (firstGame[key] < secondGame[key]) return direction === "asc" ? -1 : 1;
    if (firstGame[key] > secondGame[key]) return direction === "asc" ? 1 : -1;
    return 0;
  });

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

      <input
        type="text"
        placeholder="Szukaj gry po nazwie..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

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

export default App;
