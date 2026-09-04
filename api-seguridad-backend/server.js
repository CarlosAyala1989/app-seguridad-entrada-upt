require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

app.get('/health', (_request, response) => {
  response.status(200).json({ status: 'ok' });
});

app.use((_request, response) => {
  response.status(404).json({ message: 'Route not found' });
});

app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
