import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "count"]
  static values = { items: Object }

  connect() {
    const items = Object.entries(this.itemsValue)
    this.countTarget.textContent = `${items.reduce((sum, [, count]) => sum + count, 0)} references`
    if (!items.length) {
      this.listTarget.innerHTML = '<p class="text-sm text-slate-400">No dependency details have been captured yet.</p>'
      return
    }
    const max = Math.max(...items.map(([, count]) => count), 1)
    this.listTarget.innerHTML = items.map(([name, count]) => `<button type="button" data-action="click->dependency-chart#search" data-name="${this.escape(name)}" class="group grid w-full grid-cols-[minmax(7rem,12rem)_1fr_auto] items-center gap-3 text-left"><span class="truncate text-sm font-semibold text-slate-700">${this.escape(name)}</span><span class="h-2 overflow-hidden rounded-full bg-slate-100"><span class="block h-full rounded-full bg-indigo-500 transition-all group-hover:bg-indigo-600" style="width:${(count / max) * 100}%"></span></span><span class="text-sm font-bold tabular-nums text-slate-700">${count}</span></button>`).join("")
  }

  search(event) {
    const url = new URL(window.location.href)
    url.searchParams.set("query", event.currentTarget.dataset.name)
    window.location.assign(url)
  }

  escape(value) { const node = document.createElement("span"); node.textContent = value; return node.innerHTML }
}
