require 'spec_helper'

describe ApplicationController do
  describe '#current_theme' do
    context 'when neither activity nor sequence has a theme' do
      it 'sets the default theme' do
      end
    end

    context 'when the activity has a theme but not the sequence' do
      it 'returns the activity theme' do
      end
    end

    context 'when the sequence has a theme but not the activity' do
      it 'returns the sequence theme' do
      end
    end

    context 'when both sequence and activity have a theme' do
      it 'returns the sequence theme' do
      end
    end
  end

  describe '#current_project' do
    context 'when neither activity nor sequence have a project' do
      it 'returns nil' do
      end
    end

    context 'when only the activity has a project' do
      it 'returns the activity project' do
      end
    end

    context 'when only the sequence has a project' do
      it 'returns the sequence project' do
      end
    end

    context 'when both the sequence and activity have a project' do
      it 'returns the sequence project' do
      end
    end
  end
end
