// Wires the footer's Auto, Light and Dark switcher. The inline script in the page's <head> applies the theme
// before the page draws and defines window.slTheme; this only saves the choice and keeps the switcher in step.
(() => {
  const theme = window.slTheme;
  const switcher = document.querySelector(".sl-theme");
  if (theme && switcher) {
    const inputs = switcher.querySelectorAll("input[name='theme']");
    const sync = () => {
      const preference = theme.preference();
      for (const input of inputs) input.checked = input.value === preference;
    };

    for (const input of inputs) {
      input.addEventListener("change", () => {
        theme.save(input.value);
        theme.apply();
      });
    }

    // Another tab changed the choice.
    addEventListener("storage", (event) => {
      if (event.key !== theme.key) return;
      theme.apply();
      sync();
    });

    sync();
    switcher.hidden = false;
  }

  // A Copy button on each code block in a post.
  if (!navigator.clipboard) return;
  for (const block of document.querySelectorAll(".sl-prose div.highlighter-rouge, .sl-prose figure.highlight")) {
    const code = block.querySelector("pre code") || block.querySelector("pre");
    if (!code) continue;
    const button = document.createElement("button");
    button.type = "button";
    button.className = "sl-copy";
    button.textContent = "Copy";
    button.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(code.innerText);
        button.textContent = "Copied";
      } catch {
        button.textContent = "Couldn't copy";
      }
      setTimeout(() => { button.textContent = "Copy"; }, 2000);
    });
    block.append(button);
  }
})();
