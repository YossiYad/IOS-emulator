import React, { useState } from 'react';
import Editor from '@monaco-editor/react';
import axios from 'axios';

const MonacoEditorWrapper: React.FC = () => {
    const [path, setPath] = useState('/workspaces/project/main.swift');
    const [code, setCode] = useState('// open a file to edit');

    const loadFile = async () => {
        const resp = await axios.get('/api/v1/ide/read', { params: { path } , responseType: 'text' as any});
        setCode(resp.data);
    };

    const saveFile = async () => {
        await axios.post('/api/v1/ide/write?path=' + encodeURIComponent(path), code, { headers: { 'Content-Type': 'text/plain' } });
        alert('saved');
    };

    const build = async () => {
        const resp = await axios.post('/api/v1/ide/build', { path, out: '/workspaces/project/app' });
        alert(resp.data);
    };

    return (
        <div style={{ height: '70vh' }}>
            <div style={{ display: 'flex', gap: 8 }}>
                <input value={path} onChange={e => setPath(e.target.value)} style={{ flex: 1 }} />
                <button onClick={loadFile}>Open</button>
                <button onClick={saveFile}>Save</button>
                <button onClick={build}>Build</button>
            </div>
            <Editor height="90%" defaultLanguage="swift" value={code} onChange={(v) => setCode(v || '')} />
        </div>
    );
};

export default MonacoEditorWrapper;
