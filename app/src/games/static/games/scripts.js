// Function to filter table rows based on search input
document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById('searchBox');
    const table = document.getElementById('gamesTable');
    const tbody = table.getElementsByTagName('tbody')[0];
    const rows = tbody.getElementsByTagName('tr');

    searchInput.addEventListener('keyup', () => {
        const filter = searchInput.value.toLowerCase();

        for (let i = 0; i < rows.length; i++) {
            const firstTd = rows[i].getElementsByTagName('td')[0];
            if (firstTd) {
                const text = firstTd.textContent || firstTd.innerText;
                // if pass → show, if not → hide
                rows[i].style.display = text.toLowerCase().includes(filter) ? '' : 'none';
            }
        }
    });
});
