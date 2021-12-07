import * as React from "react";

import "./completion-page.scss";

export const CompletionPage = () => {
  return (
    <div className="completion-page">
      <h2 className="completion-page-title">Completion Page</h2>
      <p>The completion page is intended to be used at the end of the activity.
         Its content changes depening on how far the student is through the activity and sequence (if there is one).</p>
      <h3 className="completion-description-heading">Here are the 7 different cases that are handled</h3>
      <ol>
        <li>Single activity is not completed.</li>
        <li>Single activity is completed.</li>
        <li>Activity is part of a sequence, it's not completed and it's not the last one in sequence.</li>
        <li>Activity is part of a sequence, it's completed, but it's not the last one in sequence.</li>
        <li>Activity is part of a sequence, it's not completed, but it's the last one in sequence.</li>
        <li>Activity is part of a sequence, it's completed and it's the last one in sequence, but some other activity
            in sequence is not completed, so the whole sequence is also not completed.</li>
        <li>Activity is part of a sequence, it's completed and it's the last one in sequence, but some other activity
            in sequence is not completed, so the whole sequence is also not completed.</li>
        <li>Activity is part of a sequence, it's completed and it's the last one in sequence and all the other
          activities in sequence are completed.</li>
      </ol>
    </div>
  );
};
