class ItemsController < ApplicationController
  before_action :set_quote
  before_action :ensure_quote_is_editable
  before_action :set_item, only: %i[edit update destroy]

  def create
    @item = @quote.items.build(item_params)

    if @item.save
      prepare_quote_rendering

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to quote_path(@quote), notice: "Article ajouté avec succès" }
      end
    else
      @items = @quote.items.order(created_at: :asc)
      render "quotes/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      prepare_quote_rendering

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to quote_path(@quote), notice: "Article mis à jour avec succès" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    prepare_quote_rendering

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to quote_path(@quote), notice: "Article supprimé avec succès" }
    end
  end

  private

  def set_quote
    @quote = Quote.includes(:items).find(params[:quote_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to quotes_path, alert: "Devis non trouvé"
  end

  def set_item
    @item = @quote.items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to quote_path(@quote), alert: "Article non trouvé"
  end

  def item_params
    params.require(:item).permit(:name, :quantity, :unit_price, :vat_rate)
  end

  def prepare_quote_rendering
    @quote.reload
    @items = @quote.items.order(created_at: :asc)
    @new_item = Item.new(quote: @quote)
  end
end
