import * as React from 'react'
import * as DOM from 'react-dom'


// By making state a class we can define default values.
class AspectRatioChooserState {
  readonly width: number = 0;
  readonly height: number = 0;
  readonly mode: string = "DEFAULT";
};


interface AspectRatioChooserProps {
  disabled: boolean;
  value: number;
  label: string;
  initialState: AspectRatioChooserState;
  availableAspectRatios: [string];
  updateValues: (v:AspectRatioChooserState) => void;
}


export class AspectRatioChooser extends
  React.Component<AspectRatioChooserProps, AspectRatioChooserState> {
    getInitialState() {
      return {
        width:  this.props.initialState.width,
        height: this.props.initialState.height,
        mode: this.props.initialState.mode
      };
    }

    myUpdate(changes: any) {
      this.setState(changes);
      const delayedUpdate = () => {
        return this.props.updateValues(this.state);
      };
      return setTimeout(delayedUpdate,1);
    }

    render() {
      const { mode, width, height } = this.state;
      const { availableAspectRatios } = this.props;
      const disabledInputs = mode === 'MANUAL' ? false : true;
      const inputStyle = {
        'display': 'flex',
        'flex-direction': 'row',
        'flex-wrap': 'wrap',
        'margin-right': '0.5em',
        'opacity': disabledInputs ? '0.5' : '1.0'
      };
      return(
        <div style={inputStyle}>
          <select onChange={e => this.myUpdate({mode: e.target.value})}/>
        </div>
      )
    }
  }

