CatalogLinks =
  init: ->
    if (Conf['External Catalog'] or Conf['JSON Navigation']) and !(Conf['JSON Navigation'] and g.VIEW is 'index')
      selector = switch g.VIEW
        when 'thread', 'archive' then '.navLinks.desktop > a'
        when 'catalog' then '.navLinks > :first-child > a'
        when 'index'   then '.middlead + .desktop > a, .cataloglink > a'
      $.ready ->
        for link in $$ selector
          switch link.pathname
            when "/#{g.BOARD}/"        then link.href = CatalogLinks.index()
            when "/#{g.BOARD}/catalog" then link.href = CatalogLinks.catalog()
          if g.VIEW is 'catalog' and Conf['JSON Navigation'] and Conf['Use 4chan X Catalog']
            catalogLink = link.parentNode.cloneNode true
            catalogLink.firstElementChild.textContent = '4chan X Catalog'
            catalogLink.firstElementChild.href = CatalogLinks.catalog()
            $.after link.parentNode, [$.tn(' '), catalogLink]
        return

    if Conf['JSON Navigation'] and Conf['Use 4chan X Catalog']
      Post.callbacks.push
        name: 'Catalog Link Rewrite'
        cb:   @node
      CatalogThread.callbacks.push
        name: 'Catalog Link Rewrite'
        cb:   @node

    if Conf['Catalog Links']
      CatalogLinks.el = el = UI.checkbox 'Header catalog links', ' Catalog Links'
      el.id = 'toggleCatalog'
      input = $ 'input', el
      $.on input, 'change', @toggle
      $.sync 'Header catalog links', CatalogLinks.set
      Header.menu.addEntry
        el:    el
        order: 95

  node: ->
    for a in $$ 'a', @nodes.comment
      if m = a.href.match /^https?:\/\/boards\.4chan\.org\/([^\/]+)\/catalog(#s=.*)?/
        a.href = "//boards.4chan.org/#{m[1]}/#{m[2] or '#catalog'}"
    return

  # Set links on load or custom board list change.
  # Called by Header when both board lists (header and footer) are ready.
  initBoardList: ->
    return unless Conf['Catalog Links']
    CatalogLinks.set Conf['Header catalog links']

  toggle: ->
    $.event 'CloseMenu'
    $.set 'Header catalog links', @checked
    CatalogLinks.set @checked

  set: (useCatalog) ->
    for a in $$('a:not([data-only])', Header.boardList).concat $$('a', Header.bottomBoardList)
      continue if a.hostname not in ['boards.4chan.org', 'catalog.neet.tv', '4index.gropes.us'] or
      !(board = a.pathname.split('/')[1]) or
      board in ['f', 'status', '4chan'] or
      a.pathname.split('/')[2] is 'archive' or
      $.hasClass a, 'external'

      # Href is easier than pathname because then we don't have
      # conditions where External Catalog has been disabled between switches.
      a.href = CatalogLinks[if useCatalog then 'catalog' else 'index'] board

    CatalogLinks.el.title = "Turn catalog links #{if useCatalog then 'off' else 'on'}."

  catalog: (board=g.BOARD.ID) ->
    if Conf['External Catalog'] and board in ['a', 'c', 'g', 'biz', 'k', 'm', 'o', 'p', 'v', 'vg', 'vr', 'w', 'wg', 'cm', '3', 'adv', 'an', 'asp', 'cgl', 'ck', 'co', 'diy', 'fa', 'fit', 'gd', 'int', 'jp', 'lit', 'mlp', 'mu', 'n', 'out', 'po', 'sci', 'sp', 'tg', 'toy', 'trv', 'tv', 'vp', 'wsg', 'x', 'f', 'pol', 's4s', 'lgbt']
      "http://catalog.neet.tv/#{board}"
    else if Conf['JSON Navigation'] and Conf['Use 4chan X Catalog']
      if g.BOARD.ID is board and g.VIEW is 'index' then '#catalog' else "/#{board}/#catalog"
    else
      "/#{board}/catalog"

  index: (board=g.BOARD.ID) ->
    if Conf['JSON Navigation'] and Conf['Use 4chan X Catalog']
      if g.BOARD.ID is board and g.VIEW is 'index' then '#index' else "/#{board}/#index"
    else
      "/#{board}/"
