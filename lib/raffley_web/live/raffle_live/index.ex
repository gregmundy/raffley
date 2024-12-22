defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles
  import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    # socket =
    #   socket
    #   |> stream(:raffles, Raffles.list_raffles())
    #   |> assign(:form, to_form(%{}))

    # IO.inspect(socket.assigns.streams.raffles, label: "MOUNT")

    # socket =
    #   attach_hook(socket, :log_stream, :after_render, fn socket ->
    #     IO.inspect(socket.assigns.streams.raffles, label: "AFTER_RENDER")
    #     socket
    #   end)

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)
      |> assign(:form, to_form(params))

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <.banner :if={false}>
        <.icon name="hero-sparkles-solid" /> Mystery Raffle Coming Soon!
        <:details :let={vibe}>
          To Be Revealed Tomorrow <%= vibe %>
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner>


      <.filter_form form={@form} />

      <div class="raffles" id="raffles" phx-update="stream">
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
      </div>
    </div>
    """
  end

  attr(:form, :map, required: true)

  def filter_form(assigns) do
    ~H"""
     <.form for={@form} id="filter-form" phx-change="filter">
        <.input field={@form[:q]} placeholder="Search..." autocomplete="off" phx-debounce="500" />
        <.input type="select" field={@form[:status]} prompt="Status" options={[:upcoming, :open, :closed]} />
        <.input type="select" field={@form[:sort_by]} prompt="Sort By" options={[Prize: "prize", "Price: High to Low": "ticket_price_desc", "Price: Low to High": "ticket_price_asc"]} />
        <.link navigate={~p"/raffles"}>Reset</.link>
      </.form>
    """
  end

  attr(:raffle, Raffley.Raffles.Raffle, required: true)
  attr(:id, :string, required: true)

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <img src={@raffle.image_path} />
        <h2><%= @raffle.prize %></h2>
        <div class="details">
          <div class="price">
            $<%= @raffle.ticket_price %> / ticket
          </div>
          <.badge status={@raffle.status} />
        </div>
      </div>
    </.link>
    """
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w(q status sort_by))
      |> Map.reject(fn {_, v} -> v in ["", nil] end)

    socket = push_patch(socket, to: ~p"/raffles?#{params}")

    {:noreply, socket}
  end
end
