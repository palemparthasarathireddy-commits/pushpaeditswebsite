import os

def fix_file(filename, backup_filename):
    with open(backup_filename, 'r', encoding='utf-8') as f:
        content = f.read()

    old_modal_logic = """        // Bento click → modal
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
        document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });"""

    new_modal_logic = """        // Bento click → modal
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

        document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });"""

    # Normalize line endings for replacement
    content_norm = content.replace('\\r\\n', '\\n')
    old_norm = old_modal_logic.replace('\\r\\n', '\\n')
    new_norm = new_modal_logic.replace('\\r\\n', '\\n')

    if old_norm in content_norm:
        new_content = content_norm.replace(old_norm, new_norm)
        with open(filename, 'w', encoding='utf-8', newline='') as f:
            f.write(new_content)
        print(f"Successfully updated {filename}")
    else:
        # Try without normalization if it fails
        if old_modal_logic in content:
            new_content = content.replace(old_modal_logic, new_modal_logic)
            with open(filename, 'w', encoding='utf-8', newline='') as f:
                f.write(new_content)
            print(f"Successfully updated {filename} (non-norm)")
        else:
            print(f"Could not find target logic in {filename}")
            # Debugging: check if the problem is small differences
            if "Bento click → modal" in content:
                print("Found start of section, but full match failed.")

if __name__ == "__main__":
    backup = "portfolio_v3_backup_grid_hero.html"
    fix_file("index.html", backup)
    fix_file("portfolio.html", backup)
