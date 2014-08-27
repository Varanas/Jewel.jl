include("commands.jl")
include("objects.jl")

# Utils

function tohtml(m::MIME"text/html", x)
  HTML() do io
    writemime(io, m, x)
  end
end

# Should use CSS for width
function tohtml(m::MIME"image/png", img)
  HTML() do io
    print(io, """<img width="500px" src="data:image/png;base64,""")
    writemime(io, m, img)
    print(io, "\" />")
  end
end

function tohtml(m::MIME"image/svg+xml", img)
  HTML() do io
     writemime(io, m, img)
  end
end

# Display infrastructure

function bestmime(val)
  for mime in ("text/html", "image/svg+xml", "image/png", "text/plain")
    mimewritable(mime, val) && return MIME(symbol(mime))
  end
  error("Cannot display $val.")
end

# Catch-all fallback
function displayinline(x)
  m = bestmime(x)
  if m == MIME"text/plain"()
    Text() do io
      writemime(io, m, x)
    end
  else tohtml(m, x)
  end
end

displayinline!(req, x, bounds) =
  displayinline!(req, displayinline(x), bounds)

displayinline!(req, text::Text, bounds) =
  showresult(req, stringmime("text/plain", text), bounds)

displayinline!(req, html::HTML, bounds) =
  showresult(req, stringmime("text/html", html), bounds, html=true, under=true)

# Light Table's Console as a display

type LTConsole <: Display end

import Base: display, writemime

function display(d::LTConsole, m::MIME"text/plain", x)
  console(stringmime(m, x))
end

function display(d::LTConsole, m::MIME"text/html", x)
  console(stringmime(m, x), html = true)
end

display(d::LTConsole, m::MIME"image/png", x) = display(d, htmlimage(x))

display(d::LTConsole, x) = display(d, bestmime(x), x)