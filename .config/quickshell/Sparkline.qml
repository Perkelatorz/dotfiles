import QtQuick

import "."

// A single-series sparkline for one metric, drawn as a line with a soft area
// fill beneath it.
//
// One metric per chart on purpose. CPU, memory and GPU all read 0-100, so they
// COULD share an axis — but three lines in one 34px box needs a legend and
// three hues to tell apart, and small multiples say the same thing with none of
// that. The current value is the headline; the line is context for it.
//
// No axes, no gridlines, no labels: the y range is pinned 0-100, so the shape
// is the whole message.
Item {
    id: spark

    required property var colors
    // Newest sample last. Values are percentages, 0-100.
    property var values: []
    property color lineColor: colors.primary
    property int maxSamples: 60

    implicitHeight: 30

    onValuesChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var vs = spark.values
            var n = vs ? vs.length : 0
            var w = width, h = height
            // A single point has no slope to draw; wait for the second sample.
            if (n < 2 || w <= 0 || h <= 0) return

            // Always plot against the full window, so a partly-filled history
            // grows in from the left instead of stretching to fit.
            var span = Math.max(spark.maxSamples - 1, 1)
            var pad = 2
            var plotH = h - pad * 2
            function px(i) { return w - (n - 1 - i) * (w / span) }
            function py(v) { return pad + plotH - (Math.max(0, Math.min(100, v)) / 100) * plotH }

            // Area first, so the line sits on top of its own fill.
            ctx.beginPath()
            ctx.moveTo(px(0), h)
            for (var i = 0; i < n; i++) ctx.lineTo(px(i), py(vs[i]))
            ctx.lineTo(px(n - 1), h)
            ctx.closePath()
            var g = ctx.createLinearGradient(0, 0, 0, h)
            g.addColorStop(0, Qt.rgba(spark.lineColor.r, spark.lineColor.g, spark.lineColor.b, 0.26))
            g.addColorStop(1, Qt.rgba(spark.lineColor.r, spark.lineColor.g, spark.lineColor.b, 0.02))
            ctx.fillStyle = g
            ctx.fill()

            ctx.beginPath()
            for (var j = 0; j < n; j++) {
                if (j === 0) ctx.moveTo(px(j), py(vs[j]))
                else ctx.lineTo(px(j), py(vs[j]))
            }
            ctx.strokeStyle = spark.lineColor
            ctx.lineWidth = 1.5
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            ctx.stroke()

            // The newest sample gets a dot — it is the value the number above
            // is showing, and it anchors the eye to "now".
            ctx.beginPath()
            ctx.arc(px(n - 1), py(vs[n - 1]), 2, 0, Math.PI * 2)
            ctx.fillStyle = spark.lineColor
            ctx.fill()
        }
    }
}
