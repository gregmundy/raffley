defmodule RaffleyWeb.AdminRaffleLive.Index do
  alias Phoenix.Endpoint
  use RaffleyWeb, :live_view

  alias Raffley.Admin
  import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Raffles")
      |> stream(:raffles, Admin.list_raffles())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.header>
        <%= @page_title %>
        <:actions>
          <.link class="button" navigate={~p"/admin/raffles/new"}>New Raffle</.link>
        </:actions>
      </.header>
      <.table id="raffles" rows={@streams.raffles}>
        <:col :let={{_dom_id, raffle}} label="Prize">
          <.link navigate={~p"/raffles/#{raffle.id}"}>
            <%= raffle.prize %>
          </.link>
        </:col>
        <:col :let={{_dom_id, raffle}} label="Status">
          <.badge status={raffle.status} />
        </:col>
        <:col :let={{_dom_id, raffle}} label="Ticket Price">
          <%= raffle.ticket_price %>
        </:col>
        <:action :let={{_dom_id, raffle}}>
          <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{_dom_id, raffle}}>
          <.link phx-click="delete" phx-value-id={raffle.id} data-confirm="Are you sure?">
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    raffle = Admin.get_raffle!(id)
    {:ok, _} = Admin.delete_raffle(raffle)
    socket = stream_delete(socket, :raffles, raffle)
    {:noreply, socket}
  end
end
