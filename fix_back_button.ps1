$content = Get-Content -Path "portfolio_v3_backup_grid_hero.html" -Raw

$oldModalLogic = @'
        // Bento click → modal
        const modal = document.getElementById('modal');
        const modalVideo = document.getElementById('modalVideo');
        const modalTitle = document.getElementById('modalTitle');
        document.getElementById('modalClose').onclick = closeModal;
        modal.addEventListener('click', e => { if (e.target === modal) closeModal(); });
        document.querySelectorAll('.bento-item[data-video]').forEach(item => {
            item.addEventListener('click', function (e) {
                const target = e.currentTarget;
                const key = target.dataset.video;
                if (!key) return;
                const src = videoSrcs[key];
                if (!src) return;
                modalTitle.textContent = target.dataset.title + ' — ' + target.dataset.cat;
                modalVideo.pause();
                modalVideo.removeAttribute('src');
                modalVideo.load();
                modal.classList.add('open');
                document.body.style.overflow = 'hidden';
                modalVideo.src = src;
                modalVideo.load();
                modalVideo.play().catch(function () { });
            });
        });
        function closeModal() {
            modal.classList.remove('open');
            modalVideo.pause();
            modalVideo.src = '';
            document.body.style.overflow = '';
        }
        document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });
'@

$newModalLogic = @'
        // Bento click → modal
        const modal = document.getElementById('modal');
        const modalVideo = document.getElementById('modalVideo');
        const modalTitle = document.getElementById('modalTitle');
        
        function openModal(item) {
            const key = item.dataset.video;
            if (!key) return;
            const src = videoSrcs[key];
            if (!src) return;

            modalTitle.textContent = item.dataset.title + ' — ' + item.dataset.cat;
            modalVideo.pause();
            modalVideo.removeAttribute('src');
            modalVideo.load();
            
            modal.classList.add('open');
            document.body.style.overflow = 'hidden';
            modalVideo.src = src;
            modalVideo.load();
            modalVideo.play().catch(() => {});

            // Push state for back button handling
            history.pushState({ modalOpen: true }, '');
        }

        function closeModal(shouldGoBack = true) {
            if (!modal.classList.contains('open')) return;
            
            modal.classList.remove('open');
            modalVideo.pause();
            modalVideo.src = '';
            document.body.style.overflow = '';

            // Handle history back if closed manually
            if (shouldGoBack && history.state && history.state.modalOpen) {
                history.back();
            }
        }

        if (document.getElementById('modalClose')) {
            document.getElementById('modalClose').onclick = () => closeModal();
        }
        if (modal) {
            modal.addEventListener('click', e => { if (e.target === modal) closeModal(); });
        }
        
        document.querySelectorAll('.bento-item[data-video]').forEach(item => {
            item.addEventListener('click', function() { openModal(this); });
        });

        window.addEventListener('popstate', (e) => {
            if (modal && modal.classList.contains('open')) {
                closeModal(false);
            }
        });

        document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });
'@

# Escape regex characters if needed or just use simple string replacement
$newContent = $content.Replace($oldModalLogic, $newModalLogic)

if ($newContent -eq $content) {
    Write-Error "Replacement failed! Content was not modified."
    exit 1
}

$newContent | Set-Content -Path "index.html" -NoNewline
$newContent | Set-Content -Path "portfolio.html" -NoNewline

Write-Host "Successfully updated index.html and portfolio.html"
