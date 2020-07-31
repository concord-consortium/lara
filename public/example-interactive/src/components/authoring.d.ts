import * as React from "react";
import { IAuthoringInitInteractive } from "../../../interactive-api-client";
interface Props {
    initMessage: IAuthoringInitInteractive;
}
export interface AuthoringApiProps {
    setOutput: (output: any) => void;
    setError: (error: any) => void;
}
export declare const AuthoringComponent: React.FC<Props>;
export {};
