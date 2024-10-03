package com.jiwhiz.mydoctor.ws;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Controller;

import java.util.List;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;


@Controller
@RequiredArgsConstructor
@Slf4j
public class MessageController {

    private final ChatClient.Builder chatClientBuilder;

    private final VectorStore vectorStore;

    @Value("classpath:/rag-prompt-template.txt")
    private Resource ragPromptTemplate;


    @MessageMapping("/chat")
    @SendToUser("/queue")
    public MessageDTO chat(@Payload MessageDTO message) {
        log.info("Message received: {}", message);

        List<Document> similarDocuments = vectorStore
            .similaritySearch(SearchRequest.query(message.content())
            .withTopK(2));
        List<String> contentList = similarDocuments.stream()
            .map(Document::getContent)
            .toList();
        log.debug("Found similar docs:\n{}", String.join("\n", contentList));

        var response = chatClientBuilder.build()
                .prompt()
                .user(
                    userSpec -> userSpec
                        .text(ragPromptTemplate)
                        .param("input", message.content())
                        .param("documents", String.join("\n", contentList))
                )
                .functions("healthRecordFunction")
                .call()
                .content();
        log.info("Message response: {}", response);

        return new MessageDTO(response);
    }

}

