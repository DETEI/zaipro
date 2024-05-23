class Edit extends App.Controller
  constructor: (params) ->
    super
    @ticket_id = null
    @csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    @jwtToken = localStorage.getItem('jwtToken')
    @controllerBind('ui::ticket::load', (data) =>
      return if data.ticket_id.toString() isnt @ticket.id.toString()

      @ticket   = App.Ticket.find(@ticket.id)
      if data.form_meta
        @formMeta = data.form_meta
      @render(data.draft)
    )
    @render()

  render: (draft = {}) =>
    defaults = @ticket.attributes()
    delete defaults.article # ignore article infos

    taskState = @taskGet('ticket')
    handlers = @Config.get('TicketZoomFormHandler')

    if !_.isEmpty(taskState)
      defaults = _.extend(defaults, taskState)
      # remove core workflow data because it should trigger a request to get data
      # for the new ticket + eventually changed task state
      @formMeta.core_workflow = undefined

    # reset updated_at for the sidbar because we render a new state
    # it is used to compare the ticket with the rendered data later
    # and needed to prevent race conditions
    @el.removeAttr('data-ticket-updated-at')

    @controllerFormSidebarTicket = new App.ControllerForm(
      elReplace:      @el
      model:          { className: 'Ticket', configure_attributes: @formMeta.configure_attributes || App.Ticket.configure_attributes }
      screen:         'edit'
      handlersConfig: handlers
      filter:         @formMeta.filter
      formMeta:       @formMeta
      params:         _.extend(defaults, draft)
      isDisabled:     @isDisabledByFollowupRules(defaults)
      taskKey:        @taskKey
      core_workflow: {
        callbacks: [@markForm]
      }
      articleParamsCallback: @parent.articleParams
      #bookmarkable:  true
    )

    # set updated_at for the sidbar because we render a new state
    @el.attr('data-ticket-updated-at', defaults.updated_at)
    console.log defaults.updated_at
    @markForm(true)

    return if @resetBind
    @resetBind = true

    @controllerBind('ui::ticket::articleNew::change', (data) =>
      return if data.ticket_id.toString() isnt @ticket.id.toString()

      @controllerFormSidebarTicket.lastChangedAttribute = 'article'
      @controllerFormSidebarTicket.runCoreWorkflow('article')
    )
    @controllerBind('ui::ticket::taskReset', (data) =>
      return if data.ticket_id.toString() isnt @ticket.id.toString()
      @render()
    ) 

  isDisabledByFollowupRules: (attributes) =>
    return false if @ticket.userGroupAccess('change')

    group           = App.Group.find(attributes.group_id)
    ticketStateType = App.TicketState.find(attributes.state_id).name
    if ticketStateType == 'closed'
      @getTicketById(@ticket.id)
    initialState    = !@ticket.editable()

    return initialState if ticketStateType isnt 'closed'

    switch group.follow_up_possible
      when 'yes'
        return initialState
      when 'new_ticket'
        return true
      when 'new_ticket_after_certain_time'
        closed_since = (new Date - Date.parse(@ticket.last_close_at)) / (24 * 60 * 60 * 1000)

        return closed_since >= group.reopen_time_in_days

  # Localizar el evento del botón para abrir el formulario del feedback
  document.addEventListener 'DOMContentLoaded', ->
    feedbackButton = document.getElementById('feedbackButton')
    feedbackButton?.addEventListener 'click', handleFeedbackClick

    # Agregar evento para envío del formulario
    feedbackForm = document.getElementById('feedbackForm')
    feedbackForm?.addEventListener 'submit', handleFeedbackFormSubmit

  # Consultar el ticket
  getTicketById: (ticket_id) =>
    fetch "/api/v1/tickets/#{ticket_id}",
      method: 'GET'
      headers:
        'Content-Type': 'application/json'
    .then (response) =>
      unless response.ok
        throw new Error 'Network response was not ok'
      response.json()
    .then (data) =>
      console.log 'Ticket data:', data
      @ticket_id = data.id
      console.log 'ID: ', @ticket_id
    .catch (error) =>
      console.error 'There was a problem with the fetch operation:', error

  window.handleFeedbackClick = ->
    console.log 'Me presionan'
    $('.feedback_modal').show()

  # Manejar el envío del formulario de feedback
  handleFeedbackFormSubmit = (event) ->
    event.preventDefault()

    tikedID = document.getElementById('ticket_id').value
    problemSolved = document.getElementById('problem_solved').value
    advisorRating = document.getElementById('advisor_rating').value
    comments = document.getElementById('comments').value

    console.log 'ticket ID: ', tikedID
    data =
      ticket_id: tikedID
      problem_solved: problemSolved
      advisor_rating: advisorRating
      comments: comments

    url = "/api/v1/tickets/#{ticket_id}"
    queryParams = new URLSearchParams(data).toString()
    fullUrl = "#{url}?#{queryParams}"

    fetch fullUrl,
      method: 'GET'
      headers:
        'Content-Type': 'application/json'
    .then (response) =>
      unless response.ok
        throw new Error 'Network response was not ok'
      response.json()
    .then (data) =>
      console.log 'Ticket data:', data
      document.querySelector('.feedback_modal').style.display = 'none'
      document.querySelector('#feedbackButton').style.display = 'none'
      alert 'Gracias por tu feedback!'
    .catch (error) =>
      console.error 'There was a problem with the fetch operation:', error

class SidebarTicket extends App.Controller
  constructor: ->
    super
    @controllerBind('config_update_local', (data) => @configUpdated(data))

  configUpdated: (data) ->
    if data.name != 'kb_active'
      return

    if data.value
      return

    @editTicket(@el)

  sidebarItem: =>
    @item = {
      name: 'ticket'
      badgeIcon: 'message'
      sidebarHead: __('Ticket')
      sidebarCallback: @editTicket
    }
    if @ticket.currentView() is 'agent'
      @item.sidebarActions = []
      @item.sidebarActions.push(
        title:    __('History')
        name:     'ticket-history'
        callback: @showTicketHistory
      )
      if @ticket.editable()
        @item.sidebarActions.push(
          title:    __('Merge')
          name:     'ticket-merge'
          callback: @showTicketMerge
        )
        @item.sidebarActions.push(
          title:    __('Change Customer')
          name:     'customer-change'
          callback: @changeCustomer
        )
    @item

  reload: (args) =>

    # apply tag changes
    if @tagWidget
      if args.tags
        @tagWidget.reload(args.tags)
      if args.mentions
        @mentionWidget.reload(args.mentions)
      if args.tagAdd
        @tagWidget.add(args.tagAdd, args.source)
      if args.tagRemove
        @tagWidget.remove(args.tagRemove)

    # apply link changes
    if @linkWidget && args.links
      @linkWidget.reload(args.links)

    if @linkKbAnswerWidget && args.links
      @linkKbAnswerWidget.reload(args.links)

    if @timeUnitWidget && args.time_accountings
      @timeUnitWidget.reload(args.time_accountings)

  editTicket: (el) =>
    @el = el
    localEl = $(App.view('ticket_zoom/sidebar_ticket')())

    @edit = new Edit(
      object_id: @ticket.id
      ticket:    @ticket
      el:        localEl.find('.edit')
      taskGet:   @taskGet
      formMeta:  @formMeta
      markForm:  @markForm
      taskKey:   @taskKey
      parent:    @parent
    )

    if @ticket.currentView() is 'agent'
      @mentionWidget = new App.WidgetMention(
        el:       localEl.filter('.js-subscriptions')
        object:   @ticket
        mentions: @mentions
      )
      @tagWidget = new App.WidgetTag(
        el:          localEl.filter('.js-tags')
        object_type: 'Ticket'
        object:      @ticket
        tags:        @tags
        editable:    @ticket.editable()
      )
      @linkWidget = new App.WidgetLink.Ticket(
        el:          localEl.filter('.js-links')
        object_type: 'Ticket'
        object:      @ticket
        links:       @links
        editable:    @ticket.editable()
      )

      if @permissionCheck('knowledge_base.*') and App.Config.get('kb_active')
        @linkKbAnswerWidget = new App.WidgetLinkKbAnswer(
          el:          localEl.filter('.js-linkKbAnswers')
          object_type: 'Ticket'
          object:      @ticket
          links:       @links
          editable:    @ticket.editable()
        )

      @timeUnitWidget = new App.TicketZoomTimeUnit(
        el:        localEl.filter('.js-timeUnit')
        object_id: @ticket.id
        time_accountings: @time_accountings
      )
    @html localEl

  showTicketHistory: =>
    new App.TicketHistory(
      ticket_id: @ticket.id
      container: @el.closest('.content')
    )

  showTicketMerge: =>
    new App.TicketMerge(
      ticket:    @ticket
      taskKey:   @taskKey
      container: @el.closest('.content')
    )

  changeCustomer: =>
    new App.TicketCustomer(
      ticket_id: @ticket.id
      container: @el.closest('.content')
    )

App.Config.set('100-TicketEdit', SidebarTicket, 'TicketZoomSidebar')