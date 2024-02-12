# frozen_string_literal: true

# ClientsController handles CRUD operations for clients in the application.
# It requires authentication for all actions and ensures that each action
# operates on the client associated with the current user.
#
class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]

  # GET /clients or /clients.json
  def index
    @clients = current_user.clients.includes(:invoices)
    apply_search_query if params[:query].present?
    apply_pagination
  end

  def sort_column
    %w[first_name email nif].include?(params[:sort]) ? params[:sort] : 'first_name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # GET /clients/1 or /clients/1.json
  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit; end

  # POST /clients or /clients.json
  def create
    @client = build_client
    @client.user = current_user
    respond_to { |format| handle_response(format) }
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to { |format| handle_update_response(format) }
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy

    respond_to do |format|
      format.html do
        redirect_to clients_url, notice: I18n.t('client_destroyed')
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  def apply_search_query
    @clients = @clients.search(params[:query])
  end

  def apply_pagination
    @pagy, @clients = pagy(@clients.reorder(sort_column => sort_direction), items: params.fetch(:count, 10))
  end

  def build_client
    Client.new(client_params)
  end

  def handle_response(format)
    if @client.save
      format.html { redirect_to clients_url, notice: I18n.t('client_created') }
      format.json { render :show, status: :created, location: @client }
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @client.errors, status: :unprocessable_entity }
    end
  end

  def handle_update_response(format)
    if @client.update(client_params)
      format.html { redirect_to clients_url, notice: I18n.t('client_updated') }
      format.json { render :show, status: :ok, location: @client }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @client.errors, status: :unprocessable_entity }
    end
  end

  # Only allow a list of trusted parameters through.
  def client_params # rubocop:disable Metrics/MethodLength
    params.require(:client).permit(
      :user_id,
      :first_name,
      :last_name,
      :nif,
      :street,
      :city,
      :region,
      :postal_code,
      :country,
      :email,
      :telephone,
      :active
    )
  end
end
