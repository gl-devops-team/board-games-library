import './App.css'
import { useEffect, useMemo, useState } from "react";
import { BrowserRouter as Router, Routes, Route, useNavigate } from "react-router-dom";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
      </Routes>
    </Router>
  )
}
function Home() {
  const [games, setGames] = useState([]);
  const [search, setSearch] = useState("");
  const [sortConfig, setSortConfig] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    fetch(`${import.meta.env.VITE_API_URL ?? ""}/api/games/`)
      .then(res => res.json())
      .then(data => {
        console.log("DATA:", data);
        setGames(data);
      })
      .catch(err => console.error("BŁĄD:", err));
  }, []);

  // Filter function
  const filteredGames = useMemo( () =>
    games.filter(game =>
      game.name.toLowerCase().includes(search.toLowerCase())
  ), [games, search]);

  // Sorting function
  const sortedGames = useMemo( () => 
    [...filteredGames].sort((firstGame, secondGame) => {
    if (!sortConfig) return 0;

    const { key, direction } = sortConfig;
    if (firstGame[key] < secondGame[key]) return direction === "asc" ? -1 : 1;
    if (firstGame[key] > secondGame[key]) return direction === "asc" ? 1 : -1;
    return 0;
  }), [filteredGames, sortConfig]);

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

      <div class="table-header">
        <input
          type="text"
          placeholder="Szukaj gry po nazwie..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />

        <button onClick={() => navigate("/login")}> Login </button>
      </div>

      <table>
        <thead>
          <tr>
            <th onClick={() => handleSort("name")}>Nazwa ▲▼</th>
            <th onClick={() => handleSort("min_players")}>Liczba graczy ▲▼</th>
            <th onClick={() => handleSort("game_time_minutes")}>Czas gry ▲▼</th>
            <th onClick={() => handleSort("category")}>Kategoria ▲▼</th>
          </tr>
        </thead>
        <tbody>
          {sortedGames.length > 0 ? (
            sortedGames.map((game, index) => (
              <tr key={index}>
                <td>{game.name}</td>
                <td>{game.min_players}-{game.max_players}</td>
                <td>{game.game_time_minutes} min</td>
                <td>{game.category}</td>
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

function Login() {
  return (
    <div className='login-container'>
      <h1>Logowanie</h1>
      <input type="text" placeholder='Nazwa użytkownika'></input>
      <input type="password" placeholder='Hasło'></input>
      <button>Zaloguj się</button>
    </div>
  )
}

export default App;
