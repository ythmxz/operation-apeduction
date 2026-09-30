class_name Transitions


## Fades the scene transparently over 0.5 seconds.
static var FADE := AlphaTransition.new()

## Fades through black over 0.5 seconds.
static var FADE_BLACK := FadeTransition.new()

## Fades through white over 0.5 seconds.
static var FADE_WHITE := FadeTransition.new(0.5, Color.WHITE)

## Fades through black over 1.0 seconds.
static var FADE_SLOW := FadeTransition.new(1.0)

## Slides left over 0.3 seconds.
static var SLIDE_LEFT := SlideTransition.new(0.3, SlideTransition.Direction.LEFT)

## Slides right over 0.3 seconds.
static var SLIDE_RIGHT := SlideTransition.new(0.3, SlideTransition.Direction.RIGHT)

## Slides up over 0.3 seconds.
static var SLIDE_UP := SlideTransition.new(0.3, SlideTransition.Direction.UP)

## Slides down over 0.3 seconds.
static var SLIDE_DOWN := SlideTransition.new(0.3, SlideTransition.Direction.DOWN)
