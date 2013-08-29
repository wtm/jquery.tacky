# ----------------------------------------------------------------------
#  Project: jQuery.Tacky
#  Description: Sticky menu with changing active element
#  Author: Scott Elwood
#  Maintained By: We the Media, inc.
#  License: MIT
#
#  Version: 1.0
# ----------------------------------------------------------------------

(($, window, document, undefined_) ->
  pluginName = 'tacky'

  defaults = 
    tackedClass: 'tacked'
    itemSelector: 'a'
    parentSelector: null
    activeClass: 'active'
    scrollSpeed: 500

  Plugin = (element, options) ->
    @options = $.extend({}, defaults, options)
    @$nav = $(element)

    @init()

    # In case of elements loading slowly, initialize again
    setTimeout (=> @init()), 500

  Plugin:: =
    init: ->
      @setGlobals()
      @getTargets()
      @createEvents()
      @getPositions()

    setGlobals: ->
      @document_height = $(document).height()
      @window_height = $(window).height()
      @nav_height = @$nav.outerHeight()

      if !@$nav.hasClass(@options.tackedClass)
        @nav_position = @$nav.offset().top

    createEvents: ->
      $(document).on "scroll.tacky", => @scroll()
      $(window).on "resize.tacky", => @setGlobals(); @scroll();

      nav_height = @nav_height
      scroll_speed = @options.scrollSpeed
      @links.on "click", (evt) ->
        evt.preventDefault()

        target_id = $(this).attr('href')
        $target = $(target_id)

        position = $target.offset().top - nav_height + 1
        $("html, body").animate({scrollTop: position}, scroll_speed)

    getTargets: ->
      item_selector = @options.itemSelector
      @links = @$nav.find(item_selector)
      @targets = @links.map -> $(this).attr('href')

    getPositions: ->
      @positions = []

      @targets.each (i, target) =>
        position = $(target).offset().top
        @positions.push position

    scroll: ->
      scroll_position = $(document).scrollTop()
      scroll_nav_position = $(document).scrollTop() + @nav_height
      scroll_mid_position = scroll_position + (@window_height / 2)
      
      if scroll_position >= @nav_position
        @toggleNav(true)

        if scroll_nav_position >= @positions[0]
          scroll_total = @document_height - @window_height
          scroll_percent = scroll_position / scroll_total

          if scroll_percent >= .99
            scroll_mid_position += @window_height

          active_i = null
          for pos, i in @positions
            if scroll_mid_position >= pos
              active_i = i

          @setActive(active_i)
        else
          @clearActive()
      else
        @toggleNav(false)
        

    toggleNav: (stick) ->
      if stick
        @$nav.addClass(@options.tackedClass)
      else
        @$nav.removeClass(@options.tackedClass)
        @clearActive()

    setActive: (i) ->
      @clearActive()

      if i >= 0
        active_class = @options.activeClass
        $active_item = @links.eq(i)
        $active_item.parent().addClass(active_class)

    clearActive: ->
      active_class = @options.activeClass
      @$nav.find('.'+active_class).removeClass(active_class)

  # ----------------------------------------------------------------------
  # ------------------------ Dirty Initialization ------------------------
  # ----------------------------------------------------------------------
  $.fn[pluginName] = (options) ->
    args = arguments
    scoped_name = "plugin_" + pluginName
    
    if options is `undefined` or typeof options is "object"
      # Initialization
      @each ->
        unless $.data(@, scoped_name)
          $.data @, scoped_name, new Plugin(@, options)

    else if typeof options is "string" and options[0] isnt "_" and options isnt "init"
      # Calling public methods
      returns = undefined
      @each ->
        instance = $.data(@, scoped_name)

        if instance instanceof Plugin and typeof instance[options] is "function"
          returns = instance[options].apply(instance, Array::slice.call(args, 1))

        $.data @, scoped_name, null  if options is "destroy"
      (if returns isnt `undefined` then returns else @)
) jQuery, window, document