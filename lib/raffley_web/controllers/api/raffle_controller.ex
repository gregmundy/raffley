defmodule RaffleyWeb.Api.RaffleController do
  use RaffleyWeb, :controller

  alias Raffley.Admin

  def index(conn, _params) do
    raffles = Admin.list_raffles()
    render(conn, :index, raffles: raffles)
  end

  def show(conn, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)
    render(conn, :show, raffle: raffle)
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> put_view(json: RaffleyWeb.ErrorJSON)
      |> render(:"404")
  end
end
