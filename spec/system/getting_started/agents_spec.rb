# Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe 'Getting Started > Agents', type: :system do
  it 'shows email address already used error' do
    visit 'getting_started/agents', skip_waiting: true

    fill_in 'firstname',        with: 'Test'
    fill_in 'lastname',         with: 'Test'
    fill_in 'email',            with: 'admin@example.com'

    click '.btn--success'

    within '.js-danger' do
      expect(page)
        .to have_text("Email address 'admin@example.com' is already used for another user.")
    end
  end

  it 'adds roles correctly' do
    visit 'getting_started/agents', skip_waiting: true

    fill_in 'email', with: 'test@example.com'

    click 'span', text: 'Admin'
    click 'span', text: 'Agent' # unselect preselected role
    click '.btn--success'

    expect(User.last).to have_attributes(
      email: 'test@example.com',
      roles: contain_exactly(
        Role.find_by(name: 'Admin')
      )
    )
  end
end