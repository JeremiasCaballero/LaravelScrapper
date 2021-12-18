<?php
namespace App\Service;

use App\Repository\SiteRepository;
use Goutte\Client;

class FenixzoneScrapper
{
    private $repository;
    private $client;

    public function __construct(SiteRepository  $repository)
    {
        $this->repository =  $repository;
        $this->client = new Client();
    }
    public function __init()
    {
        foreach ($this->repository->getAll() as $site)
        {
            $crawler = $this->client->request('GET', $site->url);
        }
    }
    private function parserCrawler($crawler)
    {
        return preg_replace('/[^A-Za-z0-9\-]/', '', $crawler->text());
    }
    private function getTItle($crawler)
    {
        return $crawler->filterXPath('//*[@id="msg_2058062"]/a');
    }
}
