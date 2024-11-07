FactoryGirl.define do
  factory :video_source, class: VideoSource do
    url 'http://example.com/video.mp4'
    format 'video/mp4'
  end
end
