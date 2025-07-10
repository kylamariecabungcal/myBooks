const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); // ✅ ITO LANG ANG ISA

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb://127.0.0.1:27017/bookmanager', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
const db = mongoose.connection;
db.on('error', console.error.bind(console, '❌ MongoDB connection error:'));
db.once('open', () => console.log('✅ Connected to MongoDB'));

// Book schema & model
const bookSchema = new mongoose.Schema({
  title: String,
  author: String,
  year: String,
});
const Book = mongoose.model('Book', bookSchema);

// Routes
app.get('/api/books', async (req, res) => {
  const books = await Book.find();
  res.json(books);
});

app.post('/api/books', async (req, res) => {
  const { title, author, year } = req.body;
  if (!title || !author || !year) {
    return res.status(400).json({ error: 'All fields are required.' });
  }

  const newBook = new Book({ title, author, year });
  await newBook.save();
  res.status(201).json(newBook);
});

app.delete('/api/books/:id', async (req, res) => {
  await Book.findByIdAndDelete(req.params.id);
  res.status(204).send();
});

// Start server
app.listen(PORT, () => {
  console.log(`📚 Server running at http://localhost:${PORT}`);
});
