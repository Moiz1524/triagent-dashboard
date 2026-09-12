import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["severity", "selection"]
  static values = { severity: Object, total: Number }

  connect() {
    const labels = ["critical", "high", "medium", "low", "information"]
    const max = Math.max(...labels.map((label) => this.severityValue[label] || 0), 1)
    const tones = { critical: "bg-red-500", high: "bg-orange-500", medium: "bg-amber-400", low: "bg-sky-500", information: "bg-slate-400" }
    this.severityTarget.innerHTML = labels.map((label) => {
      const count = this.severityValue[label] || 0
      const height = Math.max((count / max) * 100, count ? 12 : 3)
      return `<button type="button" data-action="click->findings-chart#filter" data-severity="${label}" class="group text-left" aria-label="Filter ${label} findings, ${count}"><div class="flex h-28 items-end rounded-lg bg-slate-50 p-2"><div class="w-full rounded-md ${tones[label]} transition-all duration-300 group-hover:opacity-75" style="height:${height}%"></div></div><div class="mt-2 flex justify-between text-xs"><span class="font-semibold capitalize text-slate-700">${label}</span><span class="font-bold text-slate-900">${count}</span></div></button>`
    }).join("")
  }

  filter(event) {
    const severity = event.currentTarget.dataset.severity
    const url = new URL(window.location.href)
    url.searchParams.set("severity", severity)
    window.location.assign(url)
  }
}
