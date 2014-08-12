((factory) ->
  if typeof define is "function" and define.amd
    # AMD. Register as an anonymous module.
    define ["jquery"], factory
  else
    # Browser globals
    factory jQuery
  return
) ($) ->
  defaults = {}

  $.fn.selectAreas = (options) ->
    settings = $.extend(defaults, options );

    # setup elements
    $container = $('<div>')
      .addClass('select-areas')
      .css {
        'width': @.width()
        'height': @.height()
        'top': @.offset().top
        'left': @.offset().left
      }

    $('body').append($container)

    $container
      .on 'mousedown', (e) ->
        click_y = e.pageY
        click_x = e.pageX

        $selection = $('<div>')
          .addClass('selection-box')
          .css {
            'top':    click_y
            'left':   click_x
            'width':  0
            'height': 0
          }
          .appendTo $container

        $container.on 'mousemove', (e) ->
            move_x = e.pageX
            move_y = e.pageY
            width  = Math.abs(move_x - click_x)
            height = Math.abs(move_y - click_y)

            new_x = (if (move_x < click_x) then (click_x - width) else click_x)
            new_y = (if (move_y < click_y) then (click_y - height) else click_y)

            $selection.css {
              'width': width
              'height': height
              'top': new_y
              'left': new_x
            }

      .on 'mouseup', (e) ->
            $container.off 'mousemove'
  return
