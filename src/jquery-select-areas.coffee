getBoxCSS = (elem, absolute = false) ->
  return {
      'width': elem.width()
      'height': elem.height()
      'top': (if (absolute) then elem.offset().top else elem.position().top)
      'left': (if (absolute) then elem.offset().left else elem.position().left)
    }

defaults = {
  'draggable': true
  'resizeable': true
  'disabled': false
  'labels': true
  'min_width': 40
  'min_height': 40
}

class Area
  @amount: 0
  constructor: (@instance, size, @id=Area.amount++,
                @draggable=true, @resizeable=true, label=true) ->
    if (@id > Area.amount)
      Area.amount = @id + 1

    @area = $('<div>').addClass('area').css(size)
    if label
      @area.append($('<p>').addClass('name').addClass('no-select').text(@id))
    @instance.container.append(@area)

    if @draggable
      @_make_draggable()
    if @resizeable
      @_make_resizeable()

    @_trigger_event('created')

  _trigger_event: (type) ->
    @instance.elem.trigger('area-' + type, {id: @id, size: getBoxCSS(@area)})
    return

  _get_handle: (classes, event, callback) ->
    handle = $('<div>')
      .addClass(classes)
      .on 'mousedown', (evStart) =>
        if @instance.isDisabled() then return
        if evStart.which != 1 then return  # only left mouse btn
        evStart.stopPropagation()

        @area.css({'z-index': 1000})
        currentBox = getBoxCSS(@area)

        @area
          .on 'mousemove', (evEnd) =>
            evEnd.preventDefault()

            # calulate movement
            diffX = evEnd.pageX - evStart.pageX
            diffY = evEnd.pageY - evStart.pageY
            [left, top, width, height] = callback(diffX, diffY)

            # apply movement
            box =
              left: currentBox.left + left
              top: currentBox.top + top
              width: currentBox.width + width
              height: currentBox.height + height

            # respect min size
            if box.width < @instance.options.min_width or
                box.height < @instance.options.min_height
              return

            # respect parent
            if box.left + box.width >= @instance.container.width() - 1 or
                box.top + box.height >= @instance.container.height() - 1 or
                box.left < 0 or box.top < 0
              return

            @area.css(box)
            return

      .on 'mouseup', (e) =>
        if @instance.isDisabled() then return
        e.stopPropagation()

        @area.css({'z-index': 10})
        @area.off 'mousemove'
        @_trigger_event(event)
        return

  _make_draggable: ->
    @area.addClass('area-draggable')
    @_get_handle('drag-handle', 'moved', (diffX, diffY) ->
      return [diffX, diffY, 0, 0]
    ).appendTo(@area)
    return

  _make_resizeable: ->
    @area.addClass('area-resizeable')

    # add edge handles
    @_get_handle('resize-handle left', 'resized', (diffX, diffY) ->
      return [diffX, 0, -diffX, 0]
    ).appendTo(@area)
    @_get_handle('resize-handle right', 'resized', (diffX, diffY) ->
      return [0, 0, diffX, 0]
    ).appendTo(@area)
    @_get_handle('resize-handle top', 'resized', (diffX, diffY) ->
      return [0, diffY, 0, -diffY]
    ).appendTo(@area)
    @_get_handle('resize-handle bottom', 'resized', (diffX, diffY) ->
      return [0, 0, 0, diffY]
    ).appendTo(@area)

    # add corner handles
    @_get_handle('resize-handle topleft', 'resized', (diffX, diffY) ->
      return [diffX, diffY, -diffX, -diffY]
    ).appendTo(@area)
    @_get_handle('resize-handle topright', 'resized', (diffX, diffY) ->
      return [0, diffY, diffX, -diffY]
    ).appendTo(@area)
    @_get_handle('resize-handle bottomleft', 'resized', (diffX, diffY) ->
      return [diffX, 0, -diffX, diffY]
    ).appendTo(@area)
    @_get_handle('resize-handle bottomright', 'resized', (diffX, diffY) ->
      return [0, 0, diffX, diffY]
    ).appendTo(@area)
    return

  getID: ->
    return @id

  getDimensions: ->
    return getBoxCSS(@area)

  isDraggable: ->
    return @draggable

  isResizable: ->
    return @resizable

  destroy: ->
    @area.remove()

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

    if not @isDisabled()
      @enable()  # enable all interaction

    # register mouse events
    @container
      .on 'mousedown', (e) =>
        if @isDisabled() then return
        if event.which != 1 then return  # only left mouse btn
        if @selection
          @container.trigger 'mouseup'

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
          e.preventDefault()
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
        if @isDisabled() then return

        @container.off 'mousemove'
        if not @selection
          return

        size = getBoxCSS(@selection)
        if size.width != 0 and size.height != 0
          @areas.push new Area(@, size, null, @options.draggable,
                               @options.resizeable, @options.label)
          @__labelVisibility()

        # cleanup
        @selection.remove()
        @selection = null
        return

  disable: ->
    @options.disabled = true
    @container.removeClass('area-enabled')
    return

  enable: ->
    @options.disabled = false
    @container.addClass('area-enabled')
    return

  showLabels: (show)->
    @options.labels = show
    @__labelVisibility()

  __labelVisibility: ->
    if @options.labels
      $('p.name', @container).removeClass('hide')
    else
      $('p.name', @container).addClass('hide')

  isDisabled: ->
    return @options.disabled

  removeArea: (id) ->
    toBeRemoved = []
    @areas = @areas.filter (e) -> e.getID() != id || !toBeRemoved.push e
    for area in toBeRemoved
      area.destroy()
      @elem.trigger('area-removed', id)

  addArea: (id, size) ->
    if (size.left > 0 and size.left <= @container.width() and
        size.top > 0 and size.top <= @container.height() and
        size.width > 0 and size.height > 0)
      @areas.push new Area(@, size, id, @options.draggable,
                           @options.resizeable, @options.label)
      @__labelVisibility()

  getAreas: ->
    a = {}
    for area in @areas
      a[area.getID()] = area.getDimensions()
    return a


# export to global namespace
root = exports ? this
root.SelectAreas = SelectAreas


# export as jQuery plugin
jQuery.fn.extend
  selectAreas: (options) ->
    $el = $(@)
    data = $el.data('select-area')

    if not data
      $el.data 'select-area', (data = new SelectAreas(@, options))
    return data
