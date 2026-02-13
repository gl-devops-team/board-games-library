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

            // Determine sort direction
            let direction = sortState[index] === 'asc' ? 'desc' : 'asc';
            sortState[index] = direction;

            rowsArray.sort((a, b) => {
                const aText = a.cells[index] ? a.cells[index].innerText.toLowerCase() : '';
                const bText = b.cells[index] ? b.cells[index].innerText.toLowerCase() : '';

                // Try numeric sort if possible
                const aNum = parseFloat(aText.replace(/[^0-9.-]+/g,""));
                const bNum = parseFloat(bText.replace(/[^0-9.-]+/g,""));
                if (!isNaN(aNum) && !isNaN(bNum)) {
                    return direction === 'asc' ? aNum - bNum : bNum - aNum;
                }

                // Text sort
                return direction === 'asc' ? (aText > bText ? 1 : -1) : (aText < bText ? 1 : -1);
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

        row.addEventListener('mousemove', e => {
            tooltip.style.left = e.pageX + 15 + 'px';
            tooltip.style.top = e.pageY + 15 + 'px';
        });

        row.addEventListener('mouseleave', () => {
            tooltip.style.display = 'none';
        });
    });
});
