# frozen_string_literal: true

class OrdersController < ApplicationController
  include Motor::Admin.routes.url_helpers

  wrap_parameters :order
  load_and_authorize_resource :order

  def show
    render json: @order.as_json(methods: %i[line_item_ids])
  end

  def update
    @order.update!(order_params)
  end

  def create
    assign_order_attributes(@order)

    if @order.save
      notes_params.each { |attrs| Note.create(attrs.merge(record: @order)) }

      render html: helpers.link_to(nil, motor_ui_data_path(['orders', @order.id]))
    else
      render json: { errors: @order.errors }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { errors: [e.message] }, status: :internal_server_error
  end

  private

  def assign_order_attributes(order)
    order.status = :pending
    order.customer = Customer.find_by(email: customer_params[:email]) || Customer.new(customer_params)
    order.line_items = line_items_params.map { |attrs| LineItem.new(attrs) }
  end

  def order_params
    params.permit(*Order.column_names.map(&:to_sym), line_item_ids: [])
  end

  def customer_params
    params.require(:customer).permit!
  end

  def line_items_params
    params.require(:line_items).map(&:permit!)
  end

  def notes_params
    params.require(:notes).map(&:permit!)
  end
end
