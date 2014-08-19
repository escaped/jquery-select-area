getBoxCSS = (elem, absolute = false) ->
  return {
      'width': elem.width()
      'height': elem.height()
      'top': (if (absolute) then elem.offset().top else elem.position().top)
      'left': (if (absolute) then elem.offset().left else elem.position().left)
    }

defaults = {
  'draggable': true
}

class Area
  constructor: (@parent, size, @draggable = true) ->
    @area = $('<div>').addClass('area').css(size)
    @parent.append(@area)
    if draggable
      @._make_draggable()
    return

  _make_draggable: ->
    @area
      .addClass('area-draggable')
      .on 'mouseover', =>
        @area.addClass('over')
        return
      .on 'mouseleave', =>
        @area.removeClass('over')
        return

      .on 'mousedown', (e) =>
        e.stopPropagation()
        offset_x = e.pageX - @area.offset().left
        offset_y = e.pageY - @area.offset().top

        @area
          .on 'mousemove', (e) =>
            e.stopPropagation()

            new_x = e.pageX - @parent.offset().left - offset_x
            new_y = e.pageY - @parent.offset().top - offset_y
            # respect parent
            if new_x + @area.width() >= @parent.width() - 1 or
                new_y + @area.height() >= @parent.height() - 1 or
                new_x < 0 or new_y < 0
              return

            @area.css {
              'left': new_x
              'top': new_y
            }
            return

          .on 'mouseup', (e) =>
            e.stopPropagation()
            @area.off 'mousemove'
            return
        return

  dimensions: ->
    return getBoxCSS(@area)

  draggable: ->
    return @draggable


class SelectAreas
  constructor: (@elem, options = {}) ->
    @options = $.extend(defaults, options)
    @areas = []

    # setup elements
    @selection = null
    @container = $('<div>')
      .addClass('select-areas')
      .css getBoxCSS(@elem, true)

    $('body').append(@container)

    # register mouse events
    @container
      .on 'mousedown', (e) =>
        #click_y = e.pageY
        #click_x = e.pageX
        # relative to container
        click_x = e.pageX - @container.offset().left
        click_y = e.pageY - @container.offset().top

        @selection = $('<div>')
          .addClass('area-create')
          .css {
            'top':    click_y
            'left':   click_x
            'width':  0
            'height': 0
          }
          .appendTo @container

        @container.on 'mousemove', (e) =>
          move_x = e.pageX - @container.offset().left
          move_y = e.pageY - @container.offset().top
          width  = Math.abs(move_x - click_x)
          height = Math.abs(move_y - click_y)

          new_x = (if (move_x < click_x) then (click_x - width) else click_x)
          new_y = (if (move_y < click_y) then (click_y - height) else click_y)

          @selection.css {
            'width': width
            'height': height
            'top': new_y
            'left': new_x
          }
          return
        return

      .on 'mouseup', (e) =>
        @container.off 'mousemove'
        if not @selection
          return

        size = getBoxCSS(@selection)
        if size.width != 0 and size.height != 0
          @areas.push new Area(@container, size, @options.draggable)

        # cleanup
        @selection.remove()
        @selection = null
        return
      return

    getAreas: ->
      return @area.map (area) -> area.dimensions()

# export to global namespace
root = exports ? this
root.SelectAreas = SelectAreas
