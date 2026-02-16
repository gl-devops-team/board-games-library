document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById('searchBox');
    const table = document.getElementById('gamesTable');
    const tbody = table.getElementsByTagName('tbody')[0];

    // --------------------
    // 1️⃣ Filter rows
    // --------------------
    searchInput.addEventListener('keyup', () => {
        const filter = searchInput.value.toLowerCase();
        const rows = tbody.getElementsByTagName('tr');

        for (let i = 0; i < rows.length; i++) {
            const tds = rows[i].getElementsByTagName('td');
            if (tds.length === 0) continue;
            let rowText = '';
            for (let j = 0; j < tds.length; j++) {
                rowText += tds[j].textContent.toLowerCase() + ' ';
            }
            rows[i].style.display = rowText.includes(filter) ? '' : 'none';
        }
    });

    // --------------------
    // 2️⃣ Sort table
    // --------------------
    const headers = table.getElementsByTagName('th');

    // Initialize sort state
    let sortState = {}; // columnIndex -> 'asc' / 'desc'

    Array.from(headers).forEach((header, index) => {
        header.style.cursor = 'pointer';

        header.addEventListener('click', () => {
            const rowsArray = Array.from(tbody.rows);

            let direction = sortState[index] === 'asc' ? 'desc' : 'asc';
            sortState[index] = direction;

            Array.from(headers).forEach(h => h.classList.remove('asc', 'desc'));
            header.classList.add(direction);
            
            rowsArray.sort((rowA, rowB) => {
                const aText = rowA.cells[index]
                    ? rowA.cells[index].innerText.trim().toLowerCase()
                    : '';

                const bText = rowB.cells[index]
                    ? rowB.cells[index].innerText.trim().toLowerCase()
                    : '';

                // Try numeric sort if possible
                const isANumber = /^-?\d+(\.\d+)?$/.test(aText);
                const isBNumber = /^-?\d+(\.\d+)?$/.test(bText);

                if (isANumber && isBNumber) {
                    const aNum = parseFloat(aText);
                    const bNum = parseFloat(bText);

                    return direction === 'asc'
                        ? aNum - bNum
                        : bNum - aNum;
                }

                // Text sort
                return direction === 'asc'
                    ? aText.localeCompare(bText, 'pl', { numeric: true })
                    : bText.localeCompare(aText, 'pl', { numeric: true });
            });


            // Reattach sorted rows
            rowsArray.forEach(row => tbody.appendChild(row));
        });
    });
    
    // --------------------
    // 3️⃣ Tooltip with image
    // --------------------
    const tooltip = document.createElement('div');
    tooltip.classList.add('tooltip');
    document.body.appendChild(tooltip);

    document.querySelectorAll('.game-row').forEach(row => {
        row.addEventListener('mouseenter', () => {
            const imageUrl = row.getAttribute('data-image');
            if (imageUrl) {
                tooltip.innerHTML = `<img src="${imageUrl}" alt="Game Image">`;
                tooltip.style.display = 'block';
            }
        });

        row.addEventListener('mousemove', mouseEvent => {
            tooltip.style.left = mouseEvent.pageX + 15 + 'px';
            tooltip.style.top = mouseEvent.pageY + 15 + 'px';
        });

        row.addEventListener('mouseleave', () => {
            tooltip.style.display = 'none';
        });
    });
});
