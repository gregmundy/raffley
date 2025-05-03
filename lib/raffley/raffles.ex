defmodule Raffley.Raffles do
  alias Raffley.Raffles.Raffle
  alias Raffley.Charities.Charity
  alias Raffley.Repo
  import Ecto.Query

  def list_raffles do
    Repo.all(Raffle)
  end

  def filter_raffles(filter) do
    Raffle
    |> with_status(filter["status"])
    |> with_charity(filter["charity"])
    |> search_by(filter["q"])
    |> sort_by(filter["sort_by"])
    |> preload(:charity)
    |> Repo.all()
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
    |> Repo.preload(:charity)
  end

  def featured_raffles(raffle) do
    :timer.sleep(2000)
    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end

  defp with_charity(query, slug) when slug in ["", nil] do
    query
  end

  defp with_charity(query, slug) do
    # query =
    #   from r in query,
    #     join: c in Charity,
    #     on: r.charity_id == c.id,
    #     where: c.slug == ^slug

    from r in query,
      join: c in assoc(r, :charity),
      where: c.slug == ^slug
  end


  defp sort_by(query, "prize") do
    order_by(query, :prize)
  end

  defp sort_by(query, "ticket_price_desc") do
    order_by(query, desc: :ticket_price)
  end

  defp sort_by(query, "ticket_price_asc") do
    order_by(query, :ticket_price)
  end

  defp sort_by(query, "charity") do
    from r in query,
      join: c in assoc(r, :charity),
      order_by: c.name
  end


  defp sort_by(query, _) do
    query
  end

  defp with_status(query, status) when status in ~w(upcoming open closed) do
    where(query, status: ^status)
  end

  defp with_status(query, _status) do
    query
  end

  defp search_by(query, q) when q in ["", nil] do
    query
  end

  defp search_by(query, q) do
    where(query, [r], ilike(r.prize, ^"%#{q}%"))
  end
end
