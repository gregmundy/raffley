defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles
  import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "MOUNT")
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    IO.inspect(self(), label: "HANDLE PARAMS")

    raffle = Raffles.get_raffle!(id)

    socket =
      socket
      |> assign(:raffle, raffle)
      |> assign(:page_title, raffle.prize)
      # |> assign(:featured_raffles, Raffles.featured_raffles(raffle))
      |> assign_async(:featured_raffles, fn ->
        {:ok, %{featured_raffles: Raffles.featured_raffles(raffle)}}
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    IO.inspect(self(), label: "RENDER")

    ~H"""
    <%!-- <pre>
      <%= inspect(@featured_raffles, pretty: true) %>
    </pre> --%>
    <div class="raffle-show">
      <div class="raffle">
        <img src={@raffle.image_path} />
        <section>
          <.badge status={@raffle.status} />
          <header>
            <div>
            <h2>{@raffle.prize}</h2>
            <h3>{@raffle.charity.name}</h3>
            </div>
            <div class="price">
              $<%= @raffle.ticket_price %> / ticket
            </div>
          </header>
          <div class="description">
            <%= @raffle.description %>
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left"></div>
        <div class="right">
          <.featured_raffles raffles={@featured_raffles} />
        </div>
      </div>
    </div>
    """
  end

  def featured_raffles(assigns) do
    ~H"""
    <section>
      <h4>Featured Raffles</h4>
      <.async_result :let={result} assign={@raffles}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div :if={@raffles.failed} class="failed">
            Yikes: <%= {reason} %>
          </div>
        </:failed>
        <ul class="raffles">
          <li :for={raffle <- result}>
            <.link navigate={~p"/raffles/#{raffle}"}>
              <img src={raffle.image_path} /> <%= raffle.prize %>
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end
end
