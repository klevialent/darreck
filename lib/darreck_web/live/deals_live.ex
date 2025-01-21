defmodule DarreckWeb.DealsLive do
  use DarreckWeb, :live_view

  def render(assigns) do
    ~H"""
    <table>
      <tbody id="deals"
             phx-update="stream"
             phx-viewport-bottom={"load-more"}
      >
        <%= for deal <- @deals do %>
          <tr class="deal-row" id={"deal-#{deal.id}"}>
            <td><%= deal.instrument.ticker %></td>
            <td><%= deal.quantity %></td>
            <td><%= deal.price %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 20)
     |> fetch(), temporary_assigns: [deals: []]}
  end

  defp fetch(%{assigns: %{page: page, per_page: per_page}} = socket) do
    assign(socket, deals: Darreck.Repo.Deals.list(page, per_page))
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, page: assigns.page + 1) |> fetch}
  end

end
